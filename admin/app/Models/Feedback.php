<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Feedback extends Model
{
    use HasFactory;

    protected $fillable = [
        'office_id',
        'message',
        'issue',
        'sentiment',
    ];

    // 🧠 Each feedback belongs to one office
    public function office()
    {
        return $this->belongsTo(Office::class);
    }
}