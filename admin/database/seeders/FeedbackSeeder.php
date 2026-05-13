<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class FeedbackSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $offices = \App\Models\Office::query()->pluck('id')->all();
        if (empty($offices)) {
            // If there are no offices, nothing to seed.
            return;
        }

        $messagesNeeded = 1000;

        // Enforce no duplicate feedback messages.
        $existingMessages = \App\Models\Feedback::query()
            ->whereNotNull('message')
            ->pluck('message')
            ->all();
        $existingSet = array_flip($existingMessages);

        $categories = [
            [
                'issue' => 'slow internet',
                'sentiments' => ['negative'],
                'messages' => [
                    'The internet is slow in our area.',
                    'Connection keeps dropping, the internet is slow.',
                    'The internet is slow and it takes forever to load pages.',
                    'WiFi is unstable and the internet speed is too slow.',
                    'Our classes need the internet but it is painfully slow.',
                ],
            ],
            [
                'issue' => 'unresponsive service',
                'sentiments' => ['negative'],
                'messages' => [
                    'The staff is unresponsive when we need assistance.',
                    'We waited for help but nobody responded.',
                    'Service requests are not being answered promptly.',
                    'The office is open but they do not respond to concerns.',
                    'I contacted the office and still no response.',
                ],
            ],
            [
                'issue' => 'maintenance delays',
                'sentiments' => ['negative'],
                'messages' => [
                    'Maintenance issues are taking too long to fix.',
                    'Repairs are delayed and it affects our daily work.',
                    'The problem was reported weeks ago and still not resolved.',
                    'Waiting for repairs is too slow.',
                    'They said it would be fixed soon, but there was no progress.',
                ],
            ],
            [
                'issue' => 'long processing time',
                'sentiments' => ['negative'],
                'messages' => [
                    'The processing time is too long.',
                    'Lines are long and transactions take hours.',
                    'It takes forever to complete the paperwork.',
                    'We waited too long just to get one service done.',
                    'Turnaround time is slow even with complete documents.',
                ],
            ],
            [
                'issue' => 'friendly staff',
                'sentiments' => ['positive'],
                'messages' => [
                    'The staff were friendly and accommodating.',
                    'I was treated with respect and kindness.',
                    'Staff explained everything clearly and patiently.',
                    'Good service, the team was helpful throughout.',
                    'The office experience was smooth and pleasant.',
                ],
            ],
            [
                'issue' => 'clear instructions',
                'sentiments' => ['positive'],
                'messages' => [
                    'Instructions were clear and easy to follow.',
                    'I understood the requirements right away.',
                    'They guided me step-by-step so I didn\'t get confused.',
                    'Process is well explained from start to finish.',
                    'The guidelines made it fast to complete my request.',
                ],
            ],
            [
                'issue' => 'resolution of concerns',
                'sentiments' => ['positive'],
                'messages' => [
                    'My concern was resolved quickly.',
                    'They addressed the issue and it improved after.',
                    'Thank you, the problem was fixed as promised.',
                    'Support was effective and we got a good outcome.',
                    'The follow-up was timely and the issue was handled.',
                ],
            ],
            [
                'issue' => 'cleanliness',
                'sentiments' => ['neutral', 'negative'],
                'messages' => [
                    'The area needs more attention to cleanliness.',
                    'There are times when the room is not very clean.',
                    'Maintenance of the facility should be better.',
                    'The environment could be cleaner for comfort.',
                    'Some areas look messy and need cleaning.',
                ],
            ],
            [
                'issue' => 'communication',
                'sentiments' => ['neutral', 'negative', 'positive'],
                'messages' => [
                    'Updates about requests are not consistent.',
                    'Communication could be better regarding timelines.',
                    'I received updates, and that was helpful.',
                    'They explained what to expect and that improved my experience.',
                    'I was informed in time, but some details were missing.',
                ],
            ],
        ];

        // Timeline requirement: start April 1, 2026 up until now; multiple points.
        $start = new \DateTime('2026-04-01 08:00:00');
        $now = new \DateTime();
        $totalSeconds = max(1, $now->getTimestamp() - $start->getTimestamp());

        // Spread into chunks across the timeline.
        $chunkCount = 12;
        $chunkSize = intdiv($totalSeconds, $chunkCount);

        $sentimentsForLookup = ['positive', 'negative', 'neutral'];

        $toInsert = [];
        $i = 0;

        while (count($toInsert) < $messagesNeeded) {
            $cat = $categories[array_rand($categories)];
            $officeId = $offices[array_rand($offices)];

            $messageBase = $cat['messages'][array_rand($cat['messages'])];

            // Make message unique WITHOUT using “Feedback #N”.
            // Append a deterministic unique suffix per iteration.
            $message = rtrim($messageBase) . ' (Ref: ' . ($i + 1) . ')';

            if (isset($existingSet[$message])) {
                $i++;
                continue;
            }

            $sentiment = $cat['sentiments'][array_rand($cat['sentiments'])] ?? $sentimentsForLookup[array_rand($sentimentsForLookup)];

            // created_at timeline: pick a chunk then a random second within it.
            $chunkIndex = min($chunkCount - 1, (int) floor((($i % ($chunkCount * 100))) / 100));
            $chunkStartTs = $start->getTimestamp() + ($chunkIndex * $chunkSize);
            $offsetWithinChunk = random_int(0, max(0, $chunkSize - 1));
            $createdTs = $chunkStartTs + $offsetWithinChunk;

            $createdAt = (new \DateTime())->setTimestamp($createdTs);
            $updatedAt = (clone $createdAt)->modify('+' . random_int(0, 3600) . ' seconds');

            $toInsert[] = [
                'office_id' => $officeId,
                'message' => $message,
                // DB requires `analysis` to be non-null
                'analysis' => json_encode([]),
                'issue' => $cat['issue'],
                'sentiment' => $sentiment,
                'created_at' => $createdAt->format('Y-m-d H:i:s'),
                'updated_at' => $updatedAt->format('Y-m-d H:i:s'),
            ];


            $existingSet[$message] = true;
            $i++;
        }

        // Insert columns that exist in the DB schema.
        $rows = array_map(function ($row) {
            return [
                'office_id' => $row['office_id'],
                'message' => $row['message'],
                'analysis' => $row['analysis'],
                'created_at' => $row['created_at'],
                'updated_at' => $row['updated_at'],
            ];
        }, $toInsert);

        \App\Models\Feedback::query()->insert($rows);
    }
}
