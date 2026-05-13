# TODO - LNUFeedbackSystem

## Seeder fixes
- [x] Fix `FeedbackSeeder` to insert `sentiment` into `feedback` rows (previously computed but not written).

## Validation steps (run manually)
- [x] `php artisan migrate:fresh --seed`
- [x] Verify `sentiment` is populated in `feedback` table (sentiment null = 0)
- [ ] Re-check admin dashboard sentiment counts after UI refresh.

## AI summary persistence (next likely fix)
- [ ] Check how admin dashboard reads/creates `ai_summary` and persist it (so it doesn’t “overtake” on new feedback).


