import os
import re

def main():
    lib_dir = "lib"
    pattern = re.compile(r'\.withOpacity\((.*?)\)')
    
    files_modified = 0
    replacements_made = 0

    for root, dirs, files in os.walk(lib_dir):
        for file in files:
            if file.endswith(".dart"):
                filepath = os.path.join(root, file)
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # We want to replace .withOpacity(x) with .withValues(alpha: x)
                new_content, count = pattern.subn(r'.withValues(alpha: \1)', content)
                
                if count > 0:
                    with open(filepath, 'w', encoding='utf-8') as f:
                        f.write(new_content)
                    files_modified += 1
                    replacements_made += count

    print(f"Modified {files_modified} files, made {replacements_made} replacements.")

if __name__ == "__main__":
    main()
