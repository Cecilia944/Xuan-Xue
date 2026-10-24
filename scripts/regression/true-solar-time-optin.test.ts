/**
 * 回归：issue #45 —— generateChart 此前静默忽略 BirthInfo.longitude，
 * lib/ziwei/true-solar-time.ts 的完整口径（经度差 + 均时差）无人调用。
 *
 * 本测试钉死 opt-in 修复（suggested fix #2）的三件事：
 *   ① generateChart(birthInfo, { trueSolarTime: true }) 走 true-solar-time.ts 完整口径，
 *      issue #45 的边界例（2025-12-31 23:00 HKT @ 114.17）→ 亥时、日柱留在 12-31（甲戌）；
 *   ② 默认（不传 / false）输出与修复前逐位一致 —— 金哈希用修复前代码预先算好钉死；
 *   ③ 门槛契约显式化：开启时缺 longitude / origInput 抛 RangeError，绝不静默降级。
 *
 * 另钉死一处「有意不动」：网页路径的 calcTrueSolarBranch（仅经度差、无均时差）保持原样，
 * 两套口径在时辰边界附近会分歧 —— 这是本次非破坏性 PR 刻意保留的现状。
 */
import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { generateChart } from '../../lib/ziwei/algorithm';
import { calculateTrueSolarTime } from '../../lib/ziwei/true-solar-time';
import { calcTrueSolarBranch } from '../../lib/ziwei/share';
import type { BirthInfo, ZiweiChart } from '../../lib/ziwei/types';

/** 稳定投影：剔除随今天日期漂移的字段（年龄 / 当前大限标记），其余全量参与哈希。 */
function stableJson(chart: ZiweiChart): string {
  const c = JSON.parse(JSON.stringify(chart));
  delete c.currentAge;
  delete c.currentDaXianIndex;
  for (const p of c.palaces) delete p.isCurrentDaXian;
  return JSON.stringify(c);
}
const hash = (chart: ZiweiChart) => createHash('sha256').update(stableJson(chart)).digest('hex');

/* ── ① issue #45 边界例：2025-12-31 23:00 HKT @ 香港 114.17 ────────────── */
{
  // 调用方按现有契约预调整：晚子时 23:00 → 排盘日 2026-01-01、时辰支 0（子）
  const hk: BirthInfo = {
    year: 2026, month: 1, day: 1, hour: 0, gender: 'male',
    longitude: 114.17,
    origInput: { year: 2025, month: 12, day: 31, clockHour: 23, clockMinute: 0 },
  };

  // 口径本身：真太阳时 ≈ 22:34（−23.32min 经度差 + EoT），时辰支 11（亥），不换日
  const solar = calculateTrueSolarTime({ year: 2025, month: 12, day: 31, clockHour: 23, clockMinute: 0, longitude: 114.17 });
  assert.equal(solar.corrected, true);
  assert.equal(solar.hour, 22, 'issue 例的真太阳时应为 22:34（issue 写 ≈22:34）');
  assert.equal(solar.minute, 34);
  assert.equal(solar.branch, 11, '22:34 落亥时（21:00-23:00）');
  assert.equal(solar.dayOffset, 0, '校正后不跨日，日柱留在 2025-12-31');
  assert.equal(Math.round(solar.totalCorrectionMinutes), -26, '经度差 −23.32min + 均时差 ≈ −25.98min');

  // 开启：亥时、2025-12-31、日柱甲戌 —— 与 issue 期望逐项一致
  const on = generateChart(hk, { trueSolarTime: true });
  assert.equal(on.birthInfo.hour, 11, '开启后时辰支 = 亥');
  assert.deepEqual(
    { year: on.birthInfo.year, month: on.birthInfo.month, day: on.birthInfo.day },
    { year: 2025, month: 12, day: 31 },
    '开启后排盘日回到 2025-12-31',
  );
  assert.equal(on.lunarInfo.fourPillars![2], '甲戌', '日柱 = 甲戌（issue 期望）');
  assert.equal(on.lunarInfo.fourPillars![3], '乙亥', '甲戌日亥时 → 时柱乙亥');
  assert.equal(on.mingGongBranch, 1, '命宫随亥时落在丑（未校正盘在子时命宫在子）——时辰边界整个换盘');
  assert.equal(on.shenGongBranch, 11, '身宫随亥时落在亥');

  // 开启后的盘 = 直接按校正后的排盘日/时辰支调用 generateChart 的盘（同一管线，无第二套算法）
  assert.deepEqual(
    on,
    generateChart({ ...hk, year: 2025, month: 12, day: 31, hour: 11 }),
    '校正盘应与手填校正值的盘完全一致（含 birthInfo 回填）',
  );

  // 关闭（默认）：子时、2026-01-01、日柱乙亥 —— issue 里的错误盘被原样钉为兼容行为
  const off = generateChart(hk);
  assert.equal(off.birthInfo.hour, 0, '默认时辰支 = 子（与修复前一致）');
  assert.deepEqual(
    { year: off.birthInfo.year, month: off.birthInfo.month, day: off.birthInfo.day },
    { year: 2026, month: 1, day: 1 },
    '默认排盘日 = 调用方预调整的 2026-01-01',
  );
  assert.equal(off.lunarInfo.fourPillars![2], '乙亥', '默认日柱 = 乙亥（issue 期望的旧行为）');
  assert.equal(off.lunarInfo.fourPillars![3], '丙子', '乙亥日子时 → 时柱丙子');
  assert.deepEqual(off, generateChart({ ...hk, year: 2026, month: 1, day: 1, hour: 0 }), '默认盘 = 原样输入的盘');
  console.log('  ✅ ① issue #45 边界例：开启 → 亥/2025-12-31/甲戌，默认 → 子/2026-01-01/乙亥');
}

/* ── ② 开关关闭 = 修复前逐位一致（金哈希由修复前代码预先算好） ──────────── */
{
  const cases: Record<string, BirthInfo> = {
    hk_boundary: {
      year: 2026, month: 1, day: 1, hour: 0, gender: 'male',
      longitude: 114.17,
      origInput: { year: 2025, month: 12, day: 31, clockHour: 23, clockMinute: 0 },
    },
    plain_no_longitude: { year: 2000, month: 1, day: 31, hour: 0, gender: 'male' },
    plain_with_longitude: { year: 2000, month: 1, day: 31, hour: 0, gender: 'male', longitude: 114.17 },
    noon_beijing: { year: 1990, month: 6, day: 15, hour: 6, gender: 'female', longitude: 116.4 },
    latezi_early: { year: 2024, month: 2, day: 29, hour: 0, gender: 'male', longitude: 120 },
    hai_female: { year: 1988, month: 3, day: 7, hour: 11, gender: 'female' },
    leap_month: { year: 2023, month: 4, day: 20, hour: 3, gender: 'male', longitude: 121.47 },
  };
  // 修复前代码的输出指纹（sha256 of stableJson）——默认路径一个字节都不许动
  const GOLDEN: Record<string, string> = {
    hk_boundary: '8d02e8901c87e680a4430ecb8833c642b473063123a259b5461d94ca6cf3b16e',
    plain_no_longitude: '9a161ff1066a9216a1b5754b2792a5c7b38576349d2fb57edf814b17970cadad',
    plain_with_longitude: '9cc3ac8bb9ccd7763d5cfe61ace3439d7ac3927c117adc886dfd34259ba10c4a',
    noon_beijing: '2bbfb330271ee55c062a3149bc387c12b663d0cf47fd16f583e456bd046ba61d',
    latezi_early: 'cfb2af8a1cbde8d64b1d23a1f0cf1e91f85ff8fba78ab7e460097bc79840d634',
    hai_female: 'a9729066f601f229cb0f01d96355554170048723b23d1798cfa4091836018fcb',
    leap_month: '907611130227f575d1d27796905970a3df1e8170c7dabbdcacd18035acbb223c',
  };
  for (const [name, birth] of Object.entries(cases)) {
    assert.equal(hash(generateChart(birth)), GOLDEN[name], `${name} 默认输出必须与修复前逐位一致`);
    // 开关显式关闭 / 省略 opts —— 三种调用形状输出一致
    assert.deepEqual(generateChart(birth, { trueSolarTime: false }), generateChart(birth), `${name}: trueSolarTime:false ≡ 默认`);
    assert.deepEqual(generateChart(birth, {}), generateChart(birth), `${name}: 空 opts ≡ 默认`);
    // 带 longitude 但不开开关 = 不带 longitude（仅 birthInfo 回显里多个字段，排盘结果一致）
    if (birth.longitude !== undefined) {
      const { longitude: _lng, origInput: _oi, ...without } = birth;
      const strip = (c: ZiweiChart) => { const j = JSON.parse(stableJson(c)); delete j.birthInfo; return JSON.stringify(j); };
      assert.equal(strip(generateChart(birth)), strip(generateChart(without as BirthInfo)), `${name}: 不开开关时 longitude 不参与排盘`);
    }
  }
  console.log(`  ✅ ② 默认关闭逐位一致：${Object.keys(cases).length} 组金哈希全中，trueSolarTime:false / 空 opts / 无 longitude 等价`);
}

/* ── ③ 门槛契约：开启时缺输入显式抛错，不静默降级 ──────────────────────── */
{
  const base: BirthInfo = {
    year: 2026, month: 1, day: 1, hour: 0, gender: 'male',
    longitude: 114.17,
    origInput: { year: 2025, month: 12, day: 31, clockHour: 23, clockMinute: 0 },
  };
  assert.throws(() => generateChart({ ...base, longitude: undefined }, { trueSolarTime: true }), RangeError, '缺 longitude 必须抛错');
  assert.throws(() => generateChart({ ...base, origInput: undefined }, { trueSolarTime: true }), RangeError, '缺 origInput 必须抛错');
  assert.throws(
    () => generateChart({ ...base, origInput: { year: 2025, month: 2, day: 30, clockHour: 23, clockMinute: 0 } }, { trueSolarTime: true }),
    RangeError,
    'origInput 日期不存在必须抛错',
  );
  assert.throws(
    () => generateChart({ ...base, origInput: { year: 2025, month: 12, day: 31, clockHour: 24, clockMinute: 0 } }, { trueSolarTime: true }),
    RangeError,
    'origInput 钟表时刻越界必须抛错',
  );
  // 关闭开关时缺任何字段都照旧排盘（零回归）
  assert.doesNotThrow(() => generateChart({ ...base, longitude: undefined, origInput: undefined }));
  console.log('  ✅ ③ 开启时缺 longitude / origInput / 非法输入 → RangeError；关闭时零回归');
}

/* ── ④ 校正还管两件事：均时差项、跨日回移 ─────────────────────────────── */
{
  // 均时差单独生效：经度 120 → 经度差为 0，但 EoT（此处约 −2.7min）仍把 23:00 拉回 22:57 亥时。
  // 这正是与网页路径 calcTrueSolarBranch（只算经度差）在时辰边界上的分歧点。
  const lng120: BirthInfo = {
    year: 2026, month: 1, day: 1, hour: 0, gender: 'male',
    longitude: 120,
    origInput: { year: 2025, month: 12, day: 31, clockHour: 23, clockMinute: 0 },
  };
  const on = generateChart(lng120, { trueSolarTime: true });
  assert.equal(on.birthInfo.hour, 11, '经度 120：仅均时差也把 23:00 拉回亥时');
  assert.deepEqual(on, generateChart({ ...lng120, year: 2025, month: 12, day: 31, hour: 11 }));
  assert.equal(calcTrueSolarBranch(23, 0, 120), 0, '网页口径（仅经度差）仍是子时 —— 本 PR 有意不动它');
  assert.equal(calcTrueSolarBranch(23, 0, 114.17), 11, '网页口径在 114.17 经度差已足以进亥时；分歧只在均时差项（见上一行）');

  // 跨日回移：00:10 @ 东经 100°（约 −80min）→ 真太阳时 ≈ 前一日 22:49 亥时
  const west: BirthInfo = {
    year: 2025, month: 6, day: 15, hour: 0, gender: 'female',
    longitude: 100,
    origInput: { year: 2025, month: 6, day: 15, clockHour: 0, clockMinute: 10 },
  };
  const shifted = generateChart(west, { trueSolarTime: true });
  assert.deepEqual(
    { year: shifted.birthInfo.year, month: shifted.birthInfo.month, day: shifted.birthInfo.day, hour: shifted.birthInfo.hour },
    { year: 2025, month: 6, day: 14, hour: 11 },
    '校正跨回前一日 → 排盘日 2025-06-14、亥时',
  );
  assert.deepEqual(shifted, generateChart({ ...west, year: 2025, month: 6, day: 14, hour: 11 }));
  console.log('  ✅ ④ 均时差项独立生效（经度 120 也换时辰），跨日回移正确，网页口径分歧已钉死');
}

console.log('true-solar-time opt-in regression passed');
