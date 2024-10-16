
# 🌐 Terraform with AWS S3 Hands-on Guide

Today, we explore how to use Terraform to interact with AWS, focusing on creating and managing an S3 bucket with various configurations. Let's dive into the reason why Terraform is a great choice for managing AWS infrastructure.

## Why use AWS with Terraform?

Terraform allows you to define and manage your infrastructure as **code**. This infrastructure-as-code approach enables you to store your infrastructure setup in version control systems like Git. 

Using AWS with Terraform enhances infrastructure management by introducing:
- **Automation** 🤖: You can automate the entire infrastructure setup.
- **Consistency** 🔄: Reuse your Terraform code for similar setups, ensuring uniformity.
- **Scalability** 📈: Easily manage resources across multi-cloud environments.
- **Version Control & Planning** 📝: Keep track of your infrastructure changes and plan accordingly.

Terraform is a powerful tool to simplify and streamline cloud infrastructure management, regardless of your organization's size.

---

## 💻 Hands-on Environment

This guide was built on:
- **OS**: Ubuntu 22.04 LTS
- **AWS S3 Bucket**: `ce05-bucket2`
![image](https://github.com/user-attachments/assets/ce0cf0e6-6257-4c69-8090-20ce8974693c)
![image](https://github.com/user-attachments/assets/146275b8-022e-4206-920e-9a553d86a753)


---

## 🛠️ Step-by-Step Implementation

### 1️⃣ IAM Role: `ce05-IAM`

This IAM role allows EC2 instances to assume this role.

#### Role Configuration:

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

---

### 2️⃣ IAM Policy: `ce05-policy`

The policy grants **full access** to all S3 resources.

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

---

### 3️⃣ Attach Policy to Role

```hcl
resource "aws_iam_role_policy_attachment" "attach_ce05_policy" {
  role       = aws_iam_role.ce05_IAM.name
  policy_arn = aws_iam_policy.ce05_policy.arn
}
```
### 🤖 Initialize and apply Terraform
```hcl
terraform init

terraform apply

```
![image](https://github.com/user-attachments/assets/b5d0380f-703b-4657-8d84-0a3fc297ad97)
![image](https://github.com/user-attachments/assets/428e7788-2790-491f-bd2b-e8a93e2d1665)
![image](https://github.com/user-attachments/assets/d8355adb-8e54-499f-bae3-f7f057524f70)

---

### 4️⃣ Create an S3 Bucket with Terraform

We will create a bucket `ce05-bucket2` to store files and host a static website.

```hcl
resource "aws_s3_bucket" "bucket2" {
  bucket = "ce05-bucket2"  # Name of the S3 bucket
}
```

---

### 5️⃣ Configure Public Access

```hcl
resource "aws_s3_bucket_public_access_block" "bucket2_public_access_block" {
  bucket = aws_s3_bucket.bucket2.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
```

---

### 6️⃣ Upload the `index.html` File

```hcl
resource "aws_s3_object" "index" {
  bucket        = aws_s3_bucket.bucket2.id  # S3 bucket ID
  key           = "index.html"
  source        = "index.html"
  content_type  = "text/html"
  etag          = filemd5("index.html")  # MD5 checksum to detect changes
}
```

---

### 7️⃣ Host a Static Website

```hcl
resource "aws_s3_bucket_website_configuration" "xweb_bucket_website" {
  bucket = aws_s3_bucket.bucket2.id

  index_document {
    suffix = "index.html"
  }
}
```

---

### 8️⃣ Public Access Policy for the Website

```hcl
resource "aws_s3_bucket_policy" "public_read_access" {
  bucket = aws_s3_bucket.bucket2.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": "*",
        "Action": "s3:GetObject",
        "Resource": [
          "arn:aws:s3:::ce05-bucket2",
          "arn:aws:s3:::ce05-bucket2/*"
        ]
      }
    ]
  })
}
```

### 🤖 Apply without "YES"
```hcl
 terraform apply -auto-approve
```
![image](https://github.com/user-attachments/assets/74bc72b1-499a-4ef0-8f87-f48da2af2140)
![image](https://github.com/user-attachments/assets/cc01def0-26b1-4d97-a840-3bffc43963dd)

---

### 9️⃣ Upload a New `main.html` File

Now, let’s upload `main.html` to our existing bucket:

```hcl
resource "aws_s3_object" "main_html" {
  bucket = "ce05-bucket2"
  key    = "main.html"
  source = "/home/username/Terakim/main.html"  # Local file path
  content_type = "text/html"
}
```

💻When you want to update file, USE THIS!
```hcl
etag          = filemd5("index.html")
```
This is the command which can update content. If you want to update contents, should use this command in your terrafomr file with resource command.

---

### 🔟 Output the S3 Object URL

```hcl
output "main_html_url" {
  value = "https://${aws_s3_object.main_html.bucket}.s3.amazonaws.com/${aws_s3_object.main_html.key}"
}
```

### ✅ Apply the Terraform Configuration

```bash
terraform init
terraform apply -auto-approve
```

![image](https://github.com/user-attachments/assets/b6278337-f0c0-4d1b-8c41-59ba301001c6)

This command will automatically create your IAM role, S3 bucket, and the public policies, and it will upload the `index.html` and `main.html` files to the S3 bucket. You can access the `main.html` via the URL outputted by Terraform.

---

## 📝 Conclusion

Terraform and AWS together provide a powerful way to automate and manage cloud infrastructure. By storing infrastructure as code, you can ensure your resources are created consistently, updated properly, and easily version-controlled. 

With a few simple Terraform commands, we were able to create an S3 bucket, set up public access policies, and upload files. 🎉

Happy Terraforming! 🚀
