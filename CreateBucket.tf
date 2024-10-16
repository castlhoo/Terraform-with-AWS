provider "aws" {
  region = "ap-northeast-2"  # S3 버킷이 위치한 리전으로 설정
}


resource "aws_s3_bucket" "bucket2" {
  bucket = "ce05-bucket2" # 생성하고자 하는 S3 버킷 이름
}



# S3 버킷의 public access block 설정
resource "aws_s3_bucket_public_access_block" "bucket2_public_access_block" {
  bucket = aws_s3_bucket.bucket2.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# 이미 존재하는 S3 버킷에 index.html 파일을 업로드
resource "aws_s3_object" "index" {
  bucket        = aws_s3_bucket.bucket2.id  # 생성된 S3 버킷 이름 사용
  key           = "index.html"
  source        = "index.html"
  content_type  = "text/html"
  etag          = filemd5("index.html")  # 파일이 변경될 때 MD5 체크섬을 사용해 변경 사항 감지
}


# S3 버킷의 웹사이트 호스팅 설정
resource "aws_s3_bucket_website_configuration" "xweb_bucket_website" {
  bucket = aws_s3_bucket.bucket2.id  # 생성된 S3 버킷 이름 사용

  index_document {
    suffix = "index.html"
  }
}

# S3 버킷의 public read 정책 설정
resource "aws_s3_bucket_policy" "public_read_access" {
  bucket = aws_s3_bucket.bucket2.id  # 올바른 버킷 이름 사용

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": "*",
        "Action": "s3:GetObject",
        "Resource": [
          "arn:aws:s3:::ce05-bucket2",         # 버킷 자체에 대한 접근
          "arn:aws:s3:::ce05-bucket2/*"        # 버킷 내 모든 객체에 대한 접근
        ]
      }
    ]
  })
}