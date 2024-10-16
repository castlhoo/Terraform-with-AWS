

# S3 버킷에 파일 업로드
resource "aws_s3_object" "main_html" {
  bucket = "ce05-bucket2"              # 이미 존재하는 S3 버킷 이름
  key    = "main.html"                 # S3 버킷 내에서의 파일 이름 (key)
  source = "/home/username/Terakim/main.html"  # 로컬에서 업로드할 파일 경로
  content_type = "text/html"           # 파일의 MIME 유형 (옵션)
}

# S3 객체 URL 출력
output "main_html_url" {
  value = "https://${aws_s3_object.main_html.bucket}.s3.amazonaws.com/${aws_s3_object.main_html.key}"
}
