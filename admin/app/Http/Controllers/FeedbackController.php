<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Http;
use App\Models\Feedback;

class FeedbackController extends Controller
{
    /**
     * Comprehensive profanity list (English & Tagalog).
     */
    private array $profanityList = [
        // English
        'fuck', 'shit', 'bitch', 'asshole', 'damn', 'cunt', 'dick', 'pussy',
        'bastard', 'slut', 'whore', 'retard', 'nigga', 'nigger', 'fag', 'faggot',
        'motherfucker', 'cock', 'tits', 'bullshit', 'piss', 'wanker', 'twat',

        // Tagalog
        'putangina', 'gago', 'bobo', 'tanga', 'ulol', 'pakyu', 'tangina',
        'puta', 'kantot', 'iyot', 'hinayupak', 'lintik', 'buwisit', 'tarantado',
        'leche', 'pesteng', 'pakshet', 'shunga', 'ungas', 'kupal', 'hinampak',
        'demonyo', 'bwisit', 'pucha', 'puchang', 'piste', 'yawa', 'atay',

        // Variants
        'fck', 'fuk', 'sh1t', 'b1tch', 'paky0u', 'g@go', 'b0b0',
    ];

    public function index(): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data' => Feedback::latest()->get(),
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'office_id' => 'required|exists:offices,id',
            'message'   => 'required|string|max:1500',
        ]);

        $message = trim($request->input('message'));

        // 1. Word limit (1–50 words)
        $wordCount = str_word_count($message);
        if ($wordCount < 1 || $wordCount > 50) {
            return response()->json([
                'error' => 'Feedback must be between 1 and 50 words.'
            ], 422);
        }

        // 2. Profanity filter
        if ($this->containsProfanity($message)) {
            return response()->json([
                'error' => 'Profanity detected. Please revise your feedback.'
            ], 422);
        }

        // 3. Gibberish detection
        if ($this->isGibberish($message)) {
            return response()->json([
                'error' => 'Gibberish detected. Please provide clear feedback.'
            ], 422);
        }

        // 4. AI analysis (Gemini)
        $analysis = json_decode($this->analyzeFeedback($message), true);

        // 5. Extract sentiment safely
        $sentiment = $analysis['sentiment'] ?? 'neutral';

        // 6. Extract single-word issue safely
        $issueText = $analysis['insights'] ?? 'general issue';
        $issueWords = explode(' ', strtolower($issueText));
        $issue = preg_replace('/[^a-z]/', '', $issueWords[0] ?? 'general');

        // 7. Save to DB
        $feedback = Feedback::create([
            'office_id' => $request->office_id,
            'message'   => $message,
            'issue'     => $issue,
            'sentiment' => $sentiment,
        ]);

        return response()->json([
            'success' => true,
            'data' => $feedback,
            'analysis' => $analysis,
        ]);
    }

    /**
     * Check profanity
     */
    private function containsProfanity(string $text): bool
    {
        $lower = mb_strtolower($text);

        foreach ($this->profanityList as $word) {
            if (mb_strlen($word) <= 4) {
                if (str_contains($lower, $word)) {
                    return true;
                }
            } else {
                if (preg_match('/\b' . preg_quote($word, '/') . '\b/u', $lower)) {
                    return true;
                }
            }
        }

        return false;
    }

    /**
     * Gibberish detection
     */
    private function isGibberish(string $text): bool
    {
        $words = preg_split('/\s+/u', $text, -1, PREG_SPLIT_NO_EMPTY);

        if (empty($words)) return true;

        $gibberishCount = 0;
        $totalWords = count($words);

        foreach ($words as $word) {
            $clean = preg_replace('/[^\p{L}\p{N}]/u', '', $word);
            if ($clean === '') continue;

            $len = mb_strlen($clean);

            if ($len > 15 && !$this->hasVowel($clean)) {
                $gibberishCount++;
            } elseif ($len > 7 && !$this->hasVowel($clean)) {
                $gibberishCount++;
            } elseif ($len >= 5 && $this->repetitionRatio($clean) >= 0.7) {
                $gibberishCount++;
            } elseif ($len >= 10 && preg_match('/[^aeiou\s]{8,}/i', $clean)) {
                $gibberishCount++;
            }
        }

        if ($totalWords > 0 && ($gibberishCount / $totalWords) > 0.3) {
            return true;
        }

        $letters = preg_replace('/[^\p{L}]/u', '', $text);
        $ratio = mb_strlen($letters) / max(1, mb_strlen($text));

        return $ratio < 0.2;
    }

    private function hasVowel(string $word): bool
    {
        return (bool) preg_match('/[aeiou]/i', $word);
    }

    private function repetitionRatio(string $word): float
    {
        $len = mb_strlen($word);
        if ($len === 0) return 0;

        $chars = count_chars(mb_strtolower($word), 1);
        return max($chars) / $len;
    }

    /**
     * GEMINI AI ANALYSIS (FIXED)
     */
    private function analyzeFeedback(string $message): string
    {
        try {
            $apiKey = env('GEMINI_API_KEY');

            if (!$apiKey) {
                throw new \RuntimeException('Gemini API key missing.');
            }

            $model = 'gemini-1.5-flash';

            $url = "https://generativelanguage.googleapis.com/v1beta/models/{$model}:generateContent?key={$apiKey}";

            $prompt = "Analyze this feedback and return ONLY valid JSON:
{
  \"sentiment\": \"positive|negative|neutral\",
  \"spam_risk\": \"low|medium|high\",
  \"insights\": \"short 1-line summary\",
  \"language_detected\": \"english/tagalog/cebuano/waray-waray/mixed\"
}";

            $response = Http::post($url, [
                'contents' => [
                    [
                        'parts' => [
                            ['text' => $prompt . "\n\nUser: " . $message]
                        ]
                    ]
                ],
                'generationConfig' => [
                    'temperature' => 0.2,
                    'maxOutputTokens' => 256,
                ]
            ]);

            $data = $response->json();

            $text = $data['candidates'][0]['content']['parts'][0]['text'] ?? null;

            if (!$text) {
                throw new \Exception('Invalid Gemini response');
            }

            return $text;

        } catch (\Exception $e) {
            return json_encode([
                'sentiment' => 'neutral',
                'spam_risk' => 'low',
                'insights' => 'AI unavailable',
                'language_detected' => 'unknown',
            ]);
        }
    }
}