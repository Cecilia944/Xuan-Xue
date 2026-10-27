import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import ts from 'typescript';

// Run the real hook with synchronous state/storage at its persistence boundary.
let history: { form: Record<string, unknown> }[] = [];
let stored = '';
const hooks = {
  useState: () => [history, (update: (items: typeof history) => typeof history) => { history = update(history); }],
  useEffect: () => {},
  useCallback: (callback: unknown) => callback,
};
const source = readFileSync(new URL('../../lib/ziwei/history.ts', import.meta.url), 'utf8');
const code = ts.transpileModule(source, { compilerOptions: { module: ts.ModuleKind.CommonJS } }).outputText;
const exports: Record<string, () => { save: (form: Record<string, unknown>) => void }> = {};
new Function('require', 'exports', 'localStorage', code)(
  (name: string) => { assert.equal(name, 'react'); return hooks; },
  exports,
  { setItem: (_key: string, value: string) => { stored = value; } },
);
const form = { year: '1990', month: '1', day: '1', clockHour: '8', clockMinute: '0',
  gender: 'male', unknownTime: false, name: 'Test', province: '北京', city: '北京', longitude: 116.4 };
const { save } = exports.useHistory();
save(form);
save({ ...form, province: '新疆', city: '乌鲁木齐', longitude: 87.6 });
assert.equal(history.length, 2, 'different birthplaces must survive as separate entries');
save({ ...form, unknownTime: true });
assert.equal(history.length, 3, 'an unknown time must not overwrite an exact time');
save({ ...form, name: 'Another person' });
assert.equal(history.length, 4, 'different people may share a birth time');
save(form);
assert.equal(history.length, 4, 'an identical form still refreshes its existing entry');
assert.deepEqual(JSON.parse(stored), history);
console.log('History identity regressions passed');
