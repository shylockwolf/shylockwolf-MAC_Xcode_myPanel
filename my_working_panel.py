import tkinter as tk
from tkinter import filedialog, messagebox
import os
import json
import subprocess

class FileSelectorWithConfig:
    def __init__(self, root):
        self.root = root
        self.root.title("my_working_panel")
        self.root.geometry("300x600")  # 窗口宽度调整为按钮宽度的2倍（按钮宽度为10个字符单位）
        self.root.resizable(True, True)
        
        # 配置文件路径
        self.config_file = os.path.join(os.path.dirname(os.path.abspath(__file__)), "my_working_panel.json")
        
        # 存储6个文件路径
        self.selected_files = ["" for _ in range(6)]
        
        # 创建主框架
        frame = tk.Frame(root, padx=20, pady=20)
        frame.pack(fill=tk.BOTH, expand=True)
        
        # 创建6组按钮和显示框
        self.select_buttons = []
        self.result_vars = []
        self.result_labels = []
        
        for i in range(6):
            # 创建组框架
            group_frame = tk.Frame(frame)
            group_frame.pack(pady=10, fill=tk.X)
            
            # 创建选择文件按钮
            select_button = tk.Button(
                group_frame,
                text="选择文件",
                font=("Arial", 12),
                width=10,  # 使用已经修改过的宽度
                height=2,
                bg="#2196F3",  # 蓝色背景
                fg="#1976D2",  # 蓝色文本
                activebackground="#1976D2",
                cursor="hand2",
                command=lambda index=i: self.handle_button_click(index)
            )
            select_button.pack(side=tk.LEFT, padx=10)
            self.select_buttons.append(select_button)
            
            # 创建文件名显示标签
            result_var = tk.StringVar()
            result_var.set("未选择文件")
            # 所有标签宽度都加倍
            label_width = 20
            result_label = tk.Label(
                group_frame,
                textvariable=result_var,
                font=('Arial', 12),
                width=label_width,  # 所有标签宽度都加倍
                height=1,  # 缩小到原来高度的一半
                justify=tk.CENTER,
                bg="#f0f0f0",
                padx=10,
                pady=7,
                relief=tk.SUNKEN
            )
            result_label.pack(side=tk.LEFT, padx=10)
            self.result_vars.append(result_var)
            self.result_labels.append(result_label)
        
        # 加载配置文件
        self.load_config()
    
    def handle_button_click(self, index):
        """处理按钮点击事件，根据当前状态执行选择文件或打开文件"""
        if self.select_buttons[index].cget("text") == "选择文件":
            self.select_file(index)
        else:  # 打开文件
            self.open_file(index)
    
    def select_file(self, index):
        """选择文件并保存到配置"""
        try:
            # 隐藏主窗口以显示文件对话框
            self.root.withdraw()
            
            # 打开文件选择对话框
            file_path = filedialog.askopenfilename(
                title=f"选择文件 {index + 1}",
                filetypes=[("所有文件", "*")]
            )
            
            if file_path:
                # 确保路径存在且是文件或macOS应用程序包(.app)
                is_valid = os.path.isfile(file_path) or (file_path.endswith('.app') and os.path.isdir(file_path))
                if is_valid:
                    self.selected_files[index] = file_path
                    file_name = os.path.basename(file_path)
                    self.result_vars[index].set(file_name)
                    # 更新按钮文本、颜色并将宽度缩减为原来的一半
                    self.select_buttons[index].config(text="打开", fg="#1976D2", width=10)
                    # 保存配置
                    self.save_config()
                    print(f"成功选择文件 {index + 1}: {file_path}")
                else:
                    self.result_vars[index].set("错误: 选择的路径不是有效的文件或应用")
                    print(f"错误: 路径不是有效文件或应用: {file_path}")
        except Exception as e:
            error_msg = f"错误: {str(e)}"
            self.result_vars[index].set(error_msg)
            print(error_msg)
            messagebox.showerror("错误", str(e))
        finally:
            # 确保重新显示主窗口
            self.root.deiconify()
    
    def open_file(self, index):
        """打开已选择的文件或应用"""
        file_path = self.selected_files[index]
        # 检查路径是否存在且是文件或macOS应用程序包(.app)
        is_valid = file_path and (os.path.isfile(file_path) or (file_path.endswith('.app') and os.path.isdir(file_path)))
        
        if is_valid:
            try:
                # 根据不同操作系统打开文件
                if os.name == 'nt':  # Windows
                    os.startfile(file_path)
                elif os.name == 'posix':  # macOS 或 Linux
                    if sys.platform == 'darwin':  # macOS
                        subprocess.run(['open', file_path])
                    else:  # Linux
                        subprocess.run(['xdg-open', file_path])
                print(f"已打开 {index + 1}: {file_path}")
            except Exception as e:
                error_msg = f"无法打开: {str(e)}"
                messagebox.showerror("打开失败", error_msg)
                print(error_msg)
        else:
            messagebox.showwarning("警告", "没有选择有效的文件或应用")
    
    def save_config(self):
        """保存配置到JSON文件"""
        try:
            # 为每个文件获取修改时间，对于.app应用使用目录的修改时间
            last_modified_times = []
            for file in self.selected_files:
                if file:
                    try:
                        last_modified_times.append(os.path.getmtime(file))
                    except:
                        last_modified_times.append(0)
                else:
                    last_modified_times.append(0)
            
            config_data = {
                "selected_files": self.selected_files,
                "last_modified_times": last_modified_times
            }
            with open(self.config_file, 'w', encoding='utf-8') as f:
                json.dump(config_data, f, ensure_ascii=False, indent=2)
            print(f"配置已保存到: {self.config_file}")
        except Exception as e:
            print(f"保存配置失败: {str(e)}")
    
    def load_config(self):
        """从JSON文件加载配置"""
        try:
            if os.path.exists(self.config_file):
                with open(self.config_file, 'r', encoding='utf-8') as f:
                    config_data = json.load(f)
                
                # 检查保存的文件是否存在（兼容旧配置格式）
                if "selected_files" in config_data:
                    saved_files = config_data.get("selected_files", ["" for _ in range(6)])
                    # 确保saved_files是长度为6的列表
                    if len(saved_files) < 6:
                        saved_files.extend([""] * (6 - len(saved_files)))
                    
                    # 检查是否包含eject_devices文件
                    has_eject_device = any("eject_devices" in file for file in saved_files)
                    
                    # 如果包含eject_devices文件，将窗口宽度加倍
                    if has_eject_device:
                        self.root.geometry("600x600")  # 窗口宽度加倍
                    
                    for i in range(6):
                        if i < len(saved_files) and saved_files[i]:
                            # 检查是否为有效文件或应用程序包
                            is_valid = os.path.isfile(saved_files[i]) or (saved_files[i].endswith('.app') and os.path.isdir(saved_files[i]))
                            if is_valid:
                                self.selected_files[i] = saved_files[i]
                                file_name = os.path.basename(saved_files[i])
                                self.result_vars[i].set(file_name)
                                # 更新按钮文本、颜色并将宽度缩减为原来的一半
                                self.select_buttons[i].config(text="打开", fg="#1976D2", width=10)
                                print(f"从配置加载 {i + 1}: {saved_files[i]}")
                else:
                    # 兼容旧版配置
                    saved_file = config_data.get("selected_file", "")
                    if saved_file:
                        # 检查是否为有效文件或应用程序包
                        is_valid = os.path.isfile(saved_file) or (saved_file.endswith('.app') and os.path.isdir(saved_file))
                        if is_valid:
                            self.selected_files[0] = saved_file
                            file_name = os.path.basename(saved_file)
                            self.result_vars[0].set(file_name)
                            self.select_buttons[0].config(text="打开", fg="#1976D2", width=10)
                            print(f"从配置加载 1: {saved_file}")
        except Exception as e:
            print(f"加载配置失败: {str(e)}")

if __name__ == "__main__":
    import sys
    # 创建主窗口
    root = tk.Tk()
    # 创建应用实例
    app = FileSelectorWithConfig(root)
    # 运行主循环
    root.mainloop()