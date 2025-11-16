import { readFileSync } from 'fs';

export default {
  data() {
    return {
      files: [],
      version: '1.0',
    };
  },
  mounted() {
    // 读取 myPanel.json 文件
    const configPath = '/Users/lanma/Downloads/Program/myPanel/myPanel.json';
    try {
      const configData = JSON.parse(readFileSync(configPath, 'utf-8'));
      this.files = configData.lastOpenedFiles || [];
      this.version = configData.version || '1.0';
    } catch (error) {
      console.error('Failed to load configuration file:', error);
    }
  },
  methods: {
    selectFile(index) {
      // 处理文件选择逻辑
    },
  },
};