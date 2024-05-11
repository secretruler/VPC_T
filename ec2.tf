resource "aws_instance" "web" {
  ami           = "ami-0f58b397bc5c1f2e8"
  instance_type = "t2.micro"
  key_name = "aws830"
  subnet_id   = aws_subnet.ecomm_web_subnet.id
  vpc_security_group_ids = [aws_security_group.ecomm-web-sg.id]
  user_data = file("ecomm.sh")

  tags = {
    Name = "WEB_SERVER"
  }
}