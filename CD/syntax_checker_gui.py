import ast
import tkinter as tk
from tkinter import filedialog, messagebox, scrolledtext

def check_syntax_code():
    code = text_area.get("1.0", tk.END)
    try:
        ast.parse(code)
        messagebox.showinfo("Result", "✅ No syntax errors found")
    except SyntaxError as e:
        msg = f"❌ Syntax Error:\nLine {e.lineno}, Column {e.offset}\n{e.text.strip() if e.text else ''}\n{e.msg}"
        messagebox.showerror("Syntax Error", msg)

def open_file():
    filepath = filedialog.askopenfilename(
        filetypes=[("Python Files", "*.py"), ("All Files", "*.*")]
    )
    if filepath:
        with open(filepath, "r", encoding="utf-8") as f:
            text_area.delete("1.0", tk.END)
            text_area.insert(tk.END, f.read())

# GUI Setup
root = tk.Tk()
root.title("Compiler Front-End (Syntax Checker)")
root.geometry("700x500")

frame = tk.Frame(root)
frame.pack(pady=10)

open_btn = tk.Button(frame, text="📂 Open File", command=open_file)
open_btn.pack(side=tk.LEFT, padx=5)

check_btn = tk.Button(frame, text="✅ Check Syntax", command=check_syntax_code)
check_btn.pack(side=tk.LEFT, padx=5)

text_area = scrolledtext.ScrolledText(root, wrap=tk.WORD, width=80, height=25)
text_area.pack(padx=10, pady=10, fill=tk.BOTH, expand=True)

root.mainloop()
