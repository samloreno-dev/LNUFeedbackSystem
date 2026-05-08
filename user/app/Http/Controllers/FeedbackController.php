<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
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
        // Variants / leetspeak
        'fck', 'fuk', 'sh1t', 'b1tch', 'paky0u', 'g@go', 'b0b0',
    ];

    public function index(): JsonResponse
    {
        $feedback = Feedback::latest()->get();

        return response()->json([
            'success' => true,
            'data' => $feedback,
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'message' => 'required|string|max:1500',
            'office_id' => 'nullable|integer|exists:offices,id',
            'type_id' => 'nullable|integer',
        ]);


        $message = $request->input('message');
        $trimmedMessage = trim($message);

        // 1. Word limit (max 50 words)
        $wordCount = str_word_count($trimmedMessage);
        if ($wordCount < 1 || $wordCount > 50) {
            return response()->json(['error' => 'Feedback must be between 1 and 50 words.'], 422);
        }

        // 2. Profanity filter
        if ($this->containsProfanity($trimmedMessage)) {
            return response()->json(['error' => 'Profanity detected. Please revise your feedback.'], 422);
        }

        // 3. Gibberish detection
        if ($this->isGibberish($trimmedMessage)) {
            return response()->json(['error' => 'Gibberish or meaningless text detected. Please provide clear feedback.'], 422);
        }

        // AI Analysis with OpenAI GPT-4o-mini
        $analysis = $this->analyzeFeedback($trimmedMessage);

        // Save to DB
        $feedback = Feedback::create([
            'message' => $trimmedMessage,
            'analysis' => $analysis,
            'office_id' => $request->input('office_id'),
        ]);


        return response()->json([
            'success' => true,
            'id' => $feedback->id,
            'analysis' => $analysis,
        ]);
    }

    /**
     * Check text for profanity (case-insensitive, word boundaries).
     */
    private function containsProfanity(string $text): bool
    {
        $lower = mb_strtolower($text);
        foreach ($this->profanityList as $word) {
            // Use word boundary check for short words; substring for common variants
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
     * Heuristic gibberish detection.
     */
    private function isGibberish(string $text): bool
    {
        $words = preg_split('/\s+/u', $text, -1, PREG_SPLIT_NO_EMPTY);
        if (empty($words)) {
            return true;
        }

        $gibberishCount = 0;
        $totalWords = count($words);

        foreach ($words as $word) {
            $clean = preg_replace('/[^\p{L}\p{N}]/u', '', $word);
            if ($clean === '') {
                continue;
            }

            $len = mb_strlen($clean);

            // Flag 1: Extremely long word without vowels
            if ($len > 15 && !$this->hasVowel($clean)) {
                $gibberishCount++;
                continue;
            }

            // Flag 2: All consonants and length > 7
            if ($len > 7 && !$this->hasVowel($clean)) {
                $gibberishCount++;
                continue;
            }

            // Flag 3: High repetition of single character (>70% same char)
            if ($len >= 5 && $this->repetitionRatio($clean) >= 0.7) {
                $gibberishCount++;
                continue;
            }

            // Flag 4: Random keyboard smashing pattern (3+ consecutive consonants in a long chunk)
            if ($len >= 10 && preg_match('/[^aeiou\s]{8,}/i', $clean)) {
                $gibberishCount++;
                continue;
            }
        }

        // If more than 30% of words look like gibberish, reject
        if ($totalWords > 0 && ($gibberishCount / $totalWords) > 0.3) {
            return true;
        }

        // Flag 5: Overall text is mostly non-alphabetic (<20% letters)
        $letters = preg_replace('/[^\p{L}]/u', '', $text);
        $letterRatio = mb_strlen($letters) / max(1, mb_strlen($text));
        if ($letterRatio < 0.2) {
            return true;
        }

        return false;
    }

    private function hasVowel(string $word): bool
    {
        return (bool) preg_match('/[aeiou]/i', $word);
    }

    private function repetitionRatio(string $word): float
    {
        $len = mb_strlen($word);
        if ($len === 0) return 0.0;
        $chars = count_chars(mb_strtolower($word), 1);
        $maxCount = max($chars);
        return $maxCount / $len;
    }

    private function analyzeFeedback(string $message): string
    {
        try {
            $apiKey = env('GEMINI_API_KEY') ?: env('GEMINI_APIKEY');


            if (!is_string($apiKey) || trim($apiKey) === '') {
                throw new \RuntimeException('Gemini API key is not configured.');
            }

            $model = 'gemini-3.1-flash-lite';


            $url = 'https://generativelanguage.googleapis.com/v1beta/models/' . $model . ':generateContent?key=' . urlencode($apiKey);

            $prompt = 'You analyze user feedback. The user may write in English, Tagalog, Cebuano, or Waray-Waray. Always respond in valid JSON with these keys: {"sentiment": "positive/negative/neutral", "spam_risk": "low/medium/high", "insights": "brief summary in English", "language_detected": "english/tagalog/cebuano/waray-waray/mixed"}. Keep insights concise.';

            $payload = [
                'contents' => [
                    [
                        'role' => 'user',
                        'parts' => [
                            ['text' => $prompt . "\n\nUser feedback:\n" . $message],
                        ],
                    ],
                ],
                'generationConfig' => [
                    'temperature' => 0.2,
                    'maxOutputTokens' => 256,
                ],
            ];

            $response = \Illuminate\Http\Client\Request::create($url, 'POST')
                ->header('Content-Type', 'application/json')
                ->send();

            $status = $response->getStatusCode();
            $body = (string) $response->getBody();

            if ($status < 200 || $status >= 300) {
                throw new \RuntimeException('Gemini request failed with status ' . $status . ': ' . $body);
            }

            $decoded = json_decode($body, true);
            $text = $decoded['candidates'][0]['content']['parts'][0]['text'] ?? '';

            if (!is_string($text) || trim($text) === '') {
                throw new \RuntimeException('Gemini response missing text.');
            }

            return $text;
        } catch (\Exception $e) {
            return json_encode([
                'sentiment' => 'unknown',
                'spam_risk' => 'low',
                'insights' => 'AI unavailable',
                'language_detected' => 'unknown',
            ]);
        }
    }

}
