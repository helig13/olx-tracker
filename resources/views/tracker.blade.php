<!DOCTYPE html>
<html>
<head>
    <title>Scrape OLX</title>
</head>
<body>
<form action="{{ route('tracker-subscribe') }}" method="POST">
    @csrf
    <label for="url">OLX URL:</label>
    <input type="text" id="url" name="url" required>
@error('url') {{ $message }} @enderror
    <label for="email">Email:</label>

    <input type="email" id="email" name="email" required>
@error('email') {{ $message }} @enderror

    <button type="submit">Subscribe</button>
</form>
@if(session()->has('message')) {{ session('message') }} @endif

</body>
</html>
