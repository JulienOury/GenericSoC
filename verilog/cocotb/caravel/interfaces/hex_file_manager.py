import re

class HexFileManager:
  def __init__(self, file_name):
    self.output_file_name = file_name
    self.offset = 0
    self.origin = 0
    
  def find_first_hex_address(self, data):
    match = re.search('@([0-9a-fA-F]+)', data)
    if match:
      return int(match.group(1), 16)
    else:
      return None

  def apply_offset(self, match):
    hex_value = int(match.group(1), 16)  # Convertir le match hexadécimal en int
    offset_hex_value = hex(hex_value - self.origin + self.offset)[2:]  # Appliquer l'offset et convertir à nouveau en hex
    return '@' + offset_hex_value

  def generate_program_with_bootloader(self, bootloader_hex_path, program_hex_path, hex_offset):
    self.offset = hex_offset
  
    with open(bootloader_hex_path, 'r') as fileA, open(program_hex_path, 'r') as fileB:
      content_A = fileA.read()
      content_B = fileB.read()
      
      # Find the first address as origin
      self.origin = self.find_first_hex_address(content_B)
      
      # Appliquer l'offset aux valeurs hexadécimales préfixées par '@' dans fileB
      content_B = re.sub(r'@([0-9A-Fa-f]+)', self.apply_offset, content_B)

    with open(self.output_file_name, 'w') as output_file:
      output_file.write(content_A)
      output_file.write(content_B)

  def generate_program(self, program_hex_path):

    with open(program_hex_path, 'r') as fileA:
      content_A = fileA.read()

    with open(self.output_file_name, 'w') as output_file:
      output_file.write(content_A)

