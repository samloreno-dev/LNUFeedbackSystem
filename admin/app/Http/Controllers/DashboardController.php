<?php

namespace App\Http\Controllers;

use Illuminate\Http\JsonResponse;
use App\Models\Feedback;
use App\Models\Office;
use Illuminate\Support\Facades\Http;

class DashboardController extends Controller
{
    public function summary(): JsonResponse
    {
        // 📊 TOTAL FEEDBACK
        $totalFeedback = Feedback::count();

        // 😊 SENTIMENT BREAKDOWN (must exist in feedback table)
        $positive = Feedback::where('sentiment', 'positive')->count();
        $negative = Feedback::where('sentiment', 'negative')->count();
        $neutral  = Feedback::where('sentiment', 'neutral')->count();

        // 🔥 TOP ISSUES (your 1-word issue field)
        $topIssues = Feedback::select('issue')
            ->selectRaw('COUNT(*) as total')
            ->groupBy('issue')
            ->orderByDesc('total')
            ->limit(5)
            ->get();

        // 🏢 OFFICE FEEDBACK COUNT
        $officesRaw = Office::all();

        $offices = [];

        foreach ($officesRaw as $office) {
            $count = Feedback::where('office_id', $office->id)->count();

            $offices[$office->name] = [
                'total' => $count,
            ];
        }

        // 🤖 AI SUMMARY (Gemini)
        $aiSummary = $this->generateGeminiSummary(
            $totalFeedback,
            $positive,
            $negative,
            $neutral,
            $topIssues,
            $officesRaw
        );

        return response()->json([
            'total_feedback' => $totalFeedback,
            'positive' => $positive,
            'negative' => $negative,
            'neutral' => $neutral,
            'top_issues' => $topIssues,
            'offices' => $offices,
            'ai_summary' => $aiSummary,
        ]);
    }

    /**
     * Gemini AI summary generator
     */
    private function generateGeminiSummary(
        int $total,
        int $positive,
        int $negative,
        int $neutral,
        $topIssues,
        $offices
    ): string {
        try {
            $apiKey = env('GEMINI_API_KEY');

            if (!$apiKey) {
                return "AI summary unavailable (missing API key).";
            }

            $url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key={$apiKey}";

            $prompt = "
You are an analytics AI.

Summarize this feedback data in 1 short paragraph:

Total Feedback: $total
Positive: $positive
Negative: $negative
Neutral: $neutral

Top Issues:
" . json_encode($topIssues) . "

Offices:
" . json_encode($offices) . "

Rules:
- Keep it concise (max 3–4 sentences)
- Focus on insights, not repeating numbers
- Professional tone
";

            $response = Http::post($url, [
                'contents' => [
                    [
                        'parts' => [
                            ['text' => $prompt]
                        ]
                    ]
                ]
            ]);

            if ($response->failed()) {
                return "AI summary temporarily unavailable.";
            }

            $data = $response->json();

            return $data['candidates'][0]['content']['parts'][0]['text']
                ?? "AI summary unavailable.";

        } catch (\Exception $e) {
            return "AI summary error: " . $e->getMessage();
        }
    }
}