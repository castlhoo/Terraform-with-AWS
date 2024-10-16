# Terraform-with-AWS

Today, I use Terraform with AWS. This is the reason why use AWS with Terraform. Terraform allows you to define and manage your infrastructure as code. With Terraform, your infrastructure is managed in code, which means you can store it in version control systems like Git. In complex environments, some resources depend on others (for example, an EC2 instance depending on a security group or an S3 bucket). Using AWS with Terraform significantly enhances infrastructure management by introducing automation, consistency, and efficiency. It enables teams to manage resources in a scalable and repeatable manner, supports multi-cloud deployments, and provides transparency with version control and planning features. Overall, Terraform helps simplify and streamline cloud infrastructure management for organizations of any size.

## Hands-on environment
Ubuntu 22.04 LTS
![image](https://github.com/user-attachments/assets/ce0cf0e6-6257-4c69-8090-20ce8974693c)

## Create Hands-on file
![image](https://github.com/user-attachments/assets/146275b8-022e-4206-920e-9a553d86a753)

## 1. IAM Role: `ce05-IAM`

- **Name**: `ce05-IAM`
- **Purpose**: Allows EC2 instances to assume this role.
- **Assume Role Policy**: 
  This policy allows the EC2 service to assume the role:
  ```json
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        }
      }
    ]
  }
  ```

### 2. IAM Policy: `ce05-policy`

- **Name**: `ce05-policy`
- **Purpose**: Grants full access to all S3 resources.
- **Policy Definition**:
  This policy grants full S3 access (`s3:*`) to all S3 resources (`*`):
  ```json
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "s3:*"
        ],
        "Resource": [
          "*"
        ]
      }
    ]
  }
  ```

### 3. IAM Role Policy Attachment: `attach_ce05_policy`

- **Name**: `attach_ce05_policy`
- **Purpose**: Attaches the `ce05-policy` to the `ce05-IAM` role.
- **Role**: `ce05-IAM`
- **Policy**: `ce05-policy`
.
### 4. Initialize Terraform**:
   ```bash
   terraform init
   ```
### 5. Apply the configuration** to create the IAM role, policy, and attach the policy:
   ```bash
   terraform apply
   ```
![image](https://github.com/user-attachments/assets/b04ceea5-944f-41d0-bf8d-5e147c162782)
![image](https://github.com/user-attachments/assets/428e7788-2790-491f-bd2b-e8a93e2d1665)
![image](https://github.com/user-attachments/assets/d8355adb-8e54-499f-bae3-f7f057524f70)

This will create an IAM role named `ce05-IAM` and attach the policy `ce05-policy` that allows full access to S3 resources. 

## 2. Create Bucket with index.html
### 1. S3 Bucket: `ce05-bucket2`

```hcl
resource "aws_s3_bucket" "bucket2" {
  bucket = "ce05-bucket2"  # 생성하고자 하는 S3 버킷 이름
}
```
- **Purpose**: Creates an S3 bucket for storing files and hosting a static website.

### 2. Public Access Block: `bucket2_public_access_block`

```hcl
resource "aws_s3_bucket_public_access_block" "bucket2_public_access_block" {
  bucket = aws_s3_bucket.bucket2.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
```
- **Purpose**: Manages public access settings for the S3 bucket.
- **Settings**:
  - Allows public ACLs and bucket policies.
  - Does not restrict public bucket access.

### 3. S3 Object: `index.html`

```hcl
resource "aws_s3_object" "index" {
  bucket        = aws_s3_bucket.bucket2.id  # 생성된 S3 버킷 이름 사용
  key           = "index.html"
  source        = "index.html"
  content_type  = "text/html"
  etag          = filemd5("index.html")  # 파일이 변경될 때 MD5 체크섬을 사용해 변경 사항 감지
}
```
- **Purpose**: Uploads the `index.html` file to the bucket with public access.
- **MD5 Checksum**: Ensures that changes in the file are detected by using the MD5 checksum.

### 4. Website Hosting Configuration: `xweb_bucket_website`

```hcl
resource "aws_s3_bucket_website_configuration" "xweb_bucket_website" {
  bucket = aws_s3_bucket.bucket2.id  # 생성된 S3 버킷 이름 사용

  index_document {
    suffix = "index.html"
  }
}
```
- **Purpose**: Configures the S3 bucket for static website hosting.
- **Index Document**: Specifies `index.html` as the default document for the website.

### 5. Public Read Policy: `public_read_access`

```hcl
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
```
- **Purpose**: Grants public read access to all objects in the S3 bucket.
- **Policy**:
  - Allows anyone to retrieve objects from the bucket.
  - Applies to both the bucket itself and all its objects.

 ### 6. Apply
  ```bash
   terraform apply -auto-approve
   ```
  - It can operates command without "yes"

![image](https://github.com/user-attachments/assets/74bc72b1-499a-4ef0-8f87-f48da2af2140)
![image](https://github.com/user-attachments/assets/cc01def0-26b1-4d97-a840-3bffc43963dd)


## 3. Update File
```hcl
etag          = filemd5("index.html")  # 파일이 변경될 때 MD5 체크섬을 사용해 변경 사항 감지
```
This is the command which can update content. If you want to update contents, should use this command in your terrafomr file with resource command.

## 4. Create main.html in existing bucket 2
