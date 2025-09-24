import tkinter as tk
from tkinter import filedialog, scrolledtext
import subprocess
import os

def check_c_syntax():
    code = text_area.get("1.0", tk.END)

    # Save code to a temporary file
    tmp_file = "temp_check.c"
    with open(tmp_file, "w", encoding="utf-8") as f:
        f.write(code)

    try:
        # Run gcc with syntax-only check and strict warnings treated as errors
        result = subprocess.run(
            ["gcc", "-Wall", "-Wextra", "-Werror", "-fsyntax-only", tmp_file],
            capture_output=True, text=True
        )

        output_area.config(state=tk.NORMAL)
        output_area.delete("1.0", tk.END)

        if result.returncode == 0:
            # Green text for success
            output_area.insert(tk.END, "✅ No syntax errors found\n", "success")
        else:
            # Red text for errors
            output_area.insert(tk.END, "❌ Syntax errors:\n", "error")
            output_area.insert(tk.END, result.stderr, "error")

        output_area.config(state=tk.DISABLED)

    except FileNotFoundError:
        output_area.config(state=tk.NORMAL)
        output_area.delete("1.0", tk.END)
        output_area.insert(tk.END, "❌ GCC compiler not found! Please install GCC and add it to PATH.\n", "error")
        output_area.config(state=tk.DISABLED)
    finally:
        if os.path.exists(tmp_file):
            os.remove(tmp_file)

def open_file():
    filepath = filedialog.askopenfilename(
        filetypes=[("C Files", "*.c"), ("All Files", "*.*")]
    )
    if filepath:
        with open(filepath, "r", encoding="utf-8") as f:
            text_area.delete("1.0", tk.END)
            text_area.insert(tk.END, f.read())

# GUI Setup
root = tk.Tk()
root.title("C Syntax Checker")
root.geometry("800x600")

# Buttons
frame = tk.Frame(root)
frame.pack(pady=10)

open_btn = tk.Button(frame, text="📂 Open C File", command=open_file)
open_btn.pack(side=tk.LEFT, padx=5)

check_btn = tk.Button(frame, text="✅ Check Syntax", command=check_c_syntax)
check_btn.pack(side=tk.LEFT, padx=5)

# Text area for C code
text_area = scrolledtext.ScrolledText(root, wrap=tk.WORD, width=100, height=25)
text_area.pack(padx=10, pady=10, fill=tk.BOTH, expand=True)

# Output area for errors
output_area = scrolledtext.ScrolledText(root, wrap=tk.WORD, width=100, height=10, state=tk.DISABLED)
output_area.pack(padx=10, pady=5, fill=tk.BOTH)

# Configure tags for colors
output_area.tag_config("success", foreground="green")
output_area.tag_config("error", foreground="red")

root.mainloop()
