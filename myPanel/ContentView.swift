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
        #if DEBUG
        // 在调试模式下，将配置文件放在与应用相同的目录中
        // 这样便于开发和测试
        let currentDirectory = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        return currentDirectory.appendingPathComponent("myPanel.json")
        #else
        // 在发布模式下，将配置文件放在用户文档目录中
        // 这样可以确保有写入权限
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("myPanel.json")
        #endif
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
        .frame(minWidth: 400, idealWidth: 400, maxWidth: .infinity, 
               minHeight: 500, idealHeight: 500, maxHeight: .infinity)
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
                print("用户选择了文件: \(url.path)")
                let isFile = FileManager.default.fileExists(atPath: url.path)
                let isAppBundle = url.pathExtension == "app" && FileManager.default.fileExists(atPath: url.path)
                
                print("文件存在: \(isFile), 是应用包: \(isAppBundle)")
                
                if isFile || isAppBundle {
                    selectedFiles[index] = url.path
                    buttonLabels[index] = "打开"
                    print("更新UI状态并保存配置")
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
                    print("获取文件修改时间失败: \(filePath), 错误: \(error.localizedDescription)")
                    lastModifiedTimes.append(0)
                }
            } else {
                lastModifiedTimes.append(0)
            }
        }
        
        // 使用与myPanel.json相同的格式保存配置
        let configData: [String: Any] = [
            "lastOpenedFiles": selectedFiles,
            "preferences": [
                "theme": "default",
                "language": "en"
            ],
            "windowState": [
                "width": 800,
                "height": 600,
                "x": 0,
                "y": 0
            ],
            "last_modified_times": lastModifiedTimes
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: configData, options: .prettyPrinted)
            try jsonData.write(to: configFileURL)
            print("配置已保存到: \(configFileURL.path)")
            print("保存的文件列表: \(selectedFiles)")
        } catch {
            print("保存配置失败: \(error.localizedDescription)")
            print("配置文件路径: \(configFileURL.path)")
        }
    }
    
    private func loadConfig() {
        print("尝试加载配置文件: \(configFileURL.path)")
        guard FileManager.default.fileExists(atPath: configFileURL.path) else { 
            print("配置文件不存在")
            return 
        }
        
        do {
            let jsonData = try Data(contentsOf: configFileURL)
            print("配置文件加载成功")
            // 解析JSON格式（myPanel.json中的格式）
            if let configData = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                print("配置文件内容: \(configData)")
                // 检查是否有lastOpenedFiles字段（新格式）
                if let savedFiles = configData["lastOpenedFiles"] as? [String] {
                    print("使用新格式加载配置")
                    loadFiles(savedFiles)
                    return
                }
                // 如果没有lastOpenedFiles字段，则尝试旧格式
                else if let savedFiles = configData["selected_files"] as? [String] {
                    print("使用旧格式加载配置")
                    loadFiles(savedFiles)
                    return
                }
            }
            
            // 如果顶层不是字典，则尝试作为数组解析（旧格式直接存储文件数组）
            if let savedFiles = try JSONSerialization.jsonObject(with: jsonData) as? [String] {
                print("使用数组格式加载配置")
                loadFiles(savedFiles)
            }
        } catch {
            print("加载配置失败: \(error.localizedDescription)")
        }
    }
    
    private func loadFiles(_ files: [String]) {
        var loadedFiles = files
        // 确保有6个元素
        if loadedFiles.count < 6 {
            loadedFiles.append(contentsOf: Array(repeating: "", count: 6 - loadedFiles.count))
        }
        
        for i in 0..<min(6, loadedFiles.count) {
            if !loadedFiles[i].isEmpty {
                let isFile = FileManager.default.fileExists(atPath: loadedFiles[i])
                let isAppBundle = URL(fileURLWithPath: loadedFiles[i]).pathExtension == "app" && FileManager.default.fileExists(atPath: loadedFiles[i])
                
                if isFile || isAppBundle {
                    selectedFiles[i] = loadedFiles[i]
                    buttonLabels[i] = "打开"
                    print("从配置加载 \(i + 1): \(loadedFiles[i])")
                }
            }
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
