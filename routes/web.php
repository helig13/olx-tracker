<?php

use App\Http\Controllers\SpiderController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "web" middleware group. Make something great!
|
*/

Route::get('/', function () {
    return view('tracker');
});
Route::get('/tracker', [SpiderController::class, 'index'])->name('tracker-form');
Route::post('/tracker', [SpiderController::class, 'subscribe'])->name('tracker-subscribe');

