#!/bin/bash

sudo dnf install -y httpd wget php-fpm php-mysqli php-json php php-devel
sudo dnf -y install mariadb105-server
sudo systemctl enable --now httpd


cat << \EOF > /var/www/html/index.php
<?php
$servername = "${db_address}";
$username = "${db_username}";
$password = "${db_password}";
$dbname = "lucky_numbers";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("연결 실패: " . $conn->connect_error);
}

$lucky_numbers = [];
$message = "";

if (isset($_POST['generate'])) {
    $numbers = range(1, 45);
    shuffle($numbers);
    $lucky_numbers = array_slice($numbers, 0, 6);
    sort($lucky_numbers);
    
    $numbers_string = implode(',', $lucky_numbers);
    $sql = "INSERT INTO lottery_records (numbers) VALUES ('$numbers_string')";
    
    if ($conn->query($sql) === TRUE) {
        $message = "행운의 숫자가 성공적으로 기록되었습니다.";
    } else {
        $message = "오류: " . $conn->error;
    }
}

$sql = "SELECT numbers, created_at FROM lottery_records ORDER BY created_at DESC LIMIT 10";
$result = $conn->query($sql);

$conn->close();
?>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>로또 번호 생성기</title>
</head>
<body>
    <h1>로또 번호 생성기</h1>
    
    <form method="post">
        <input type="submit" name="generate" value="행운의 숫자 생성">
    </form>

    <?php if (!empty($lucky_numbers)): ?>
        <h2>당신의 행운의 숫자:</h2>
        <p><?php echo implode(', ', $lucky_numbers); ?></p>
    <?php endif; ?>

    <?php if ($message): ?>
        <p><?php echo $message; ?></p>
    <?php endif; ?>

    <h3>최근 생성된 행운의 숫자들</h3>
    <?php if ($result->num_rows > 0): ?>
        <ul>
        <?php while($row = $result->fetch_assoc()): ?>
            <li>숫자: <?php echo $row["numbers"]; ?> - 생성 시간: <?php echo $row["created_at"]; ?></li>
        <?php endwhile; ?>
        </ul>
    <?php else: ?>
        <p>아직 생성된 행운의 숫자가 없습니다.</p>
    <?php endif; ?>
</body>
</html>

EOF
