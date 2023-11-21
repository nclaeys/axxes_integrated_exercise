resource "aws_s3_bucket" "integrated-exercise" {
  bucket = "data-track-integrated-exercise"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_encryption" {
  bucket = "data-track-integrated-exercise"
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }

}

resource "aws_s3_bucket_public_access_block" "integrated-exercise-block" {
  bucket = aws_s3_bucket.integrated-exercise.id
  block_public_acls   = true
  block_public_policy = true
}