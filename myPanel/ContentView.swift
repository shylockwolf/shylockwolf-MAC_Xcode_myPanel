//
//  ContentView.swift
//  myPanel
//
//  Created by Shylock Wolf on 2025/11/16.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var selectedFiles: [String] = Array(repeating: "", count: 6)
    @State private var buttonLabels: [String] = Array(repeating: "选择文件", count: 6)
    @State private var configFileName = "myPanel.json"
    
    private let configFileURL: URL = {
        // 获取应用程序所在的目录
        let bundleURL = Bundle.main.bundleURL
        let appDirectory = bundleURL.deletingLastPathComponent()
        return appDirectory.appendingPathComponent("myPanel.json")
    }()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("myPanel")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                ForEach(0..<6, id: \.self) { index in
                    HStack(spacing: 15) {
                        Button(action: {
                            handleButtonClick(index: index)
                        }) {
                            Text(buttonLabels[index])
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                                .frame(width: 80, height: 40)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Text(getFileName(for: index))
                            .font(.system(size: 12))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, minHeight: 40, alignment: .leading)
                            .padding(.horizontal, 10)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
            }
        }
        .frame(minWidth: 400, minHeight: 500)
        .onAppear {
            loadConfig()
        }
    }
    
    private func handleButtonClick(index: Int) {
        if buttonLabels[index] == "选择文件" {
            selectFile(index: index)
        } else {
            openFile(index: index)
        }
    }
    
    private func selectFile(index: Int) {
        let panel = NSOpenPanel()
        panel.title = "选择文件 \(index + 1)"
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.item]
        
        if panel.runModal() == .OK {
            if let url = panel.url {
                let isFile = FileManager.default.fileExists(atPath: url.path)
                let isAppBundle = url.pathExtension == "app" && FileManager.default.fileExists(atPath: url.path)
                
                if isFile || isAppBundle {
                    selectedFiles[index] = url.path
                    buttonLabels[index] = "打开"
                    saveConfig()
                    print("成功选择文件 \(index + 1): \(url.path)")
                } else {
                    print("错误: 选择的路径不是有效的文件或应用")
                }
            }
        }
    }
    
    private func openFile(index: Int) {
        let filePath = selectedFiles[index]
        
        guard !filePath.isEmpty else {
            showAlert(title: "警告", message: "没有选择有效的文件或应用")
            return
        }
        
        let fileURL = URL(fileURLWithPath: filePath)
        let isFile = FileManager.default.fileExists(atPath: filePath)
        let isAppBundle = fileURL.pathExtension == "app" && FileManager.default.fileExists(atPath: filePath)
        
        guard isFile || isAppBundle else {
            showAlert(title: "错误", message: "文件不存在或不是有效的文件")
            return
        }
        
        do {
            if isAppBundle {
                // 打开应用程序包
                NSWorkspace.shared.openApplication(at: fileURL, configuration: NSWorkspace.OpenConfiguration())
            } else {
                // 打开普通文件
                NSWorkspace.shared.open(fileURL)
            }
            print("已打开 \(index + 1): \(filePath)")
        } catch {
            showAlert(title: "打开失败", message: error.localizedDescription)
            print("打开失败: \(error.localizedDescription)")
        }
    }
    
    private func getFileName(for index: Int) -> String {
        let filePath = selectedFiles[index]
        if filePath.isEmpty {
            return "未选择文件"
        } else {
            return URL(fileURLWithPath: filePath).lastPathComponent
        }
    }
    
    private func saveConfig() {
        var lastModifiedTimes: [TimeInterval] = []
        
        for filePath in selectedFiles {
            if !filePath.isEmpty {
                do {
                    let attributes = try FileManager.default.attributesOfItem(atPath: filePath)
                    if let modificationDate = attributes[.modificationDate] as? Date {
                        lastModifiedTimes.append(modificationDate.timeIntervalSince1970)
                    } else {
                        lastModifiedTimes.append(0)
                    }
                } catch {
                    lastModifiedTimes.append(0)
                }
            } else {
                lastModifiedTimes.append(0)
            }
        }
        
        let configData: [String: Any] = [
            "selected_files": selectedFiles,
            "last_modified_times": lastModifiedTimes
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: configData, options: .prettyPrinted)
            try jsonData.write(to: configFileURL)
            print("配置已保存到: \(configFileURL.path)")
        } catch {
            print("保存配置失败: \(error.localizedDescription)")
        }
    }
    
    private func loadConfig() {
        guard FileManager.default.fileExists(atPath: configFileURL.path) else { return }
        
        do {
            let jsonData = try Data(contentsOf: configFileURL)
            if let configData = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                
                if let savedFiles = configData["selected_files"] as? [String] {
                    var files = savedFiles
                    if files.count < 6 {
                        files.append(contentsOf: Array(repeating: "", count: 6 - files.count))
                    }
                    
                    // 检查是否包含eject_devices文件
                    _ = files.contains { $0.contains("eject_devices") } // 这个变量用于未来的窗口大小调整
                    
                    for i in 0..<min(6, files.count) {
                        if !files[i].isEmpty {
                            let isFile = FileManager.default.fileExists(atPath: files[i])
                            let isAppBundle = URL(fileURLWithPath: files[i]).pathExtension == "app" && FileManager.default.fileExists(atPath: files[i])
                            
                            if isFile || isAppBundle {
                                selectedFiles[i] = files[i]
                                buttonLabels[i] = "打开"
                                print("从配置加载 \(i + 1): \(files[i])")
                            }
                        }
                    }
                }
            }
        } catch {
            print("加载配置失败: \(error.localizedDescription)")
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.addButton(withTitle: "确定")
        alert.runModal()
    }
}

#Preview {
    ContentView()
}
