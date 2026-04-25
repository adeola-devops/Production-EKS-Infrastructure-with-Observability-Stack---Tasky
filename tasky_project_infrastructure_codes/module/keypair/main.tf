resource "aws_key_pair" "mfp_key" {
  key_name = var.key_name
  public_key = file("${path.root}/keys/mfp-key.pub")
}