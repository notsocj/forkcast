import re

def remove_unused_build_header_methods():
    files_to_clean = [
        'lib/features/professional/consultations/consultation_dashboard_page.dart'
    ]
    
    for file_path in files_to_clean:
        print(f"Cleaning {file_path}")
        
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Pattern to match _buildHeader method and _buildHeaderCard method
            header_pattern = r'  Widget _buildHeader\(\) \{.*?\n  \}\n\n'
            header_card_pattern = r'  Widget _buildHeaderCard\(.*?\) \{.*?\n  \}\n\n'
            
            # Remove both patterns using DOTALL flag to match across newlines
            content = re.sub(header_pattern, '', content, flags=re.DOTALL)
            content = re.sub(header_card_pattern, '', content, flags=re.DOTALL)
            
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
                
            print(f"✅ Cleaned {file_path}")
            
        except Exception as e:
            print(f"❌ Error cleaning {file_path}: {e}")

if __name__ == "__main__":
    remove_unused_build_header_methods()