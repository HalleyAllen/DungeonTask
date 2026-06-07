/**
 * 收藏编辑 ViewModel
 * 管理收藏编辑页的状态和业务逻辑
 */
import { Collection, CollectionTypeItem, CollectionExtra, CollectionSubItem, EditPageParams } from 'core.model';
import { CollectionRepository } from '../repository/CollectionRepository';
import { CollectionTypeRepository } from '../repository/CollectionTypeRepository';
import { DateUtil } from 'core.util';
import { HMRouterMgr } from '@hadss/hmrouter';

@Observed
export class CollectionEditViewModel {
  types: CollectionTypeItem[] = [];
  itemType: string = 'sentence';
  title: string = '';
  content: string = '';
  tag: string = '';
  // 词语扩展
  wordPinyin: string = '';
  wordExplanation: string = '';
  // 句子/台词扩展
  textSource: string = '';
  textAuthor: string = '';
  // 知识点 & 自定义类型扩展
  customDesc: string = '';

  isEdit: boolean = false;
  itemId: number = 0;

  // 新建类型弹窗
  showAddTypeDialog: boolean = false;
  newTypeLabel: string = '';

  // ===== 标签相关 =====
  /** 所有已用标签（去重） */
  allTags: string[] = [];
  /** 当前选中的标签 */
  selectedTags: string[] = [];
  /** 自定义标签输入文本 */
  tagInput: string = '';

  // ===== 截至日期 =====
  /** 截至日期时间戳(ms)，0=未设置 */
  deadline: number = 0;
  /** 截至日期展示文本 */
  deadlineText: string = '';

  // ===== 子项 =====
  /** 子项列表 */
  subItems: CollectionSubItem[] = [];
  /** 新增子项输入文本 */
  newSubItemText: string = '';

  private collectionRepo: CollectionRepository = new CollectionRepository();
  private typeRepo: CollectionTypeRepository = new CollectionTypeRepository();

  /**
   * 初始化（根据路由参数判断新增/编辑）
   */
  async init(params: EditPageParams | undefined): Promise<void> {
    await this.loadTypes();
    await this.loadAllTags();
    if (params && params.id) {
      this.isEdit = true;
      this.itemId = params.id;
      await this.loadItem();
    }
  }

  /**
   * 加载所有收藏类型
   */
  async loadTypes(): Promise<void> {
    try {
      const typeList = await this.typeRepo.queryAll();
      const list: CollectionTypeItem[] = [];
      for (let i = 0; i < typeList.length; i++) {
        const t = typeList[i];
        list.push({
          label: t.label,
          value: t.name,
          isBuiltIn: t.isBuiltIn
        });
      }
      this.types = list;
    } catch (e) {
      console.error('Load types failed:', e);
    }
  }

  /**
   * 加载所有已用标签
   */
  async loadAllTags(): Promise<void> {
    try {
      this.allTags = await this.collectionRepo.queryTags();
    } catch (e) {
      console.error('Load tags failed:', e);
    }
  }

  /**
   * 加载单个收藏项
   */
  async loadItem(): Promise<void> {
    try {
      const item = await this.collectionRepo.queryById(this.itemId);
      if (item) {
        this.itemType = item.type;
        this.title = item.title;
        this.content = item.content;
        this.tag = item.tag;
        this.selectedTags = item.tag ? item.tag.split(',').map(t => t.trim()).filter(t => t) : [];
        this.parseExtra(item.extra);
      }
    } catch (e) {
      console.error('Load item failed:', e);
    }
  }

  /**
   * 保存收藏
   */
  async save(): Promise<boolean> {
    if (!this.title.trim()) return false;

    try {
      const tagStr = this.selectedTags.join(',');
      if (this.isEdit) {
        const item = await this.collectionRepo.queryById(this.itemId);
        if (item) {
          item.type = this.itemType;
          item.title = this.title;
          item.content = this.content;
          item.extra = this.buildExtra();
          item.tag = tagStr;
          await this.collectionRepo.update(item);
        }
      } else {
        const collection = new Collection();
        collection.type = this.itemType;
        collection.title = this.title;
        collection.content = this.content;
        collection.extra = this.buildExtra();
        collection.tag = tagStr;
        collection.createTime = DateUtil.getNow();
        collection.updateTime = DateUtil.getNow();
        await this.collectionRepo.insert(collection);
      }
      return true;
    } catch (e) {
      console.error('Save collection failed:', e);
      return false;
    }
  }

  // ==================== 标签操作 ====================

  /**
   * 切换标签选中状态
   */
  toggleTag(tag: string): void {
    const idx = this.selectedTags.indexOf(tag);
    if (idx >= 0) {
      this.selectedTags.splice(idx, 1);
    } else {
      this.selectedTags.push(tag);
    }
    // 触发 @Observed 刷新
    this.selectedTags = [...this.selectedTags];
  }

  /**
   * 判断标签是否已选中
   */
  isTagSelected(tag: string): boolean {
    return this.selectedTags.indexOf(tag) >= 0;
  }

  /**
   * 添加自定义标签
   */
  addCustomTag(): void {
    const tag = this.tagInput.trim();
    if (!tag) return;
    // 去重
    if (this.selectedTags.indexOf(tag) < 0) {
      this.selectedTags.push(tag);
      this.selectedTags = [...this.selectedTags];
    }
    if (this.allTags.indexOf(tag) < 0) {
      this.allTags.push(tag);
      this.allTags = [...this.allTags];
    }
    this.tagInput = '';
  }

  /**
   * 移除已选标签
   */
  removeTag(tag: string): void {
    const idx = this.selectedTags.indexOf(tag);
    if (idx >= 0) {
      this.selectedTags.splice(idx, 1);
      this.selectedTags = [...this.selectedTags];
    }
  }

  // ==================== 截至日期 ====================

  /**
   * 设置截至日期
   */
  setDeadline(timestamp: number): void {
    this.deadline = timestamp;
    if (timestamp > 0) {
      this.deadlineText = DateUtil.formatTimestamp(timestamp);
    } else {
      this.deadlineText = '';
    }
  }

  /**
   * 清除截至日期
   */
  clearDeadline(): void {
    this.deadline = 0;
    this.deadlineText = '';
  }

  // ==================== 子项操作 ====================

  /**
   * 添加子项
   */
  addSubItem(): void {
    const text = this.newSubItemText.trim();
    if (!text) return;
    this.subItems.push({ text, completed: false });
    this.subItems = [...this.subItems];
    this.newSubItemText = '';
  }

  /**
   * 切换子项完成状态
   */
  toggleSubItem(index: number): void {
    if (index >= 0 && index < this.subItems.length) {
      this.subItems[index].completed = !this.subItems[index].completed;
      this.subItems = [...this.subItems];
    }
  }

  /**
   * 更新子项文本
   */
  updateSubItemText(index: number, text: string): void {
    if (index >= 0 && index < this.subItems.length) {
      this.subItems[index].text = text;
      this.subItems = [...this.subItems];
    }
  }

  /**
   * 删除子项
   */
  removeSubItem(index: number): void {
    if (index >= 0 && index < this.subItems.length) {
      this.subItems.splice(index, 1);
      this.subItems = [...this.subItems];
    }
  }

  /**
   * 新建自定义类型
   */
  async createNewType(): Promise<void> {
    const label = this.newTypeLabel.trim();
    if (!label) return;

    try {
      const result = await this.typeRepo.createCustom(label);
      this.showAddTypeDialog = false;
      this.newTypeLabel = '';
      await this.loadTypes();
      // 自动选中新类型
      this.itemType = result.name;
    } catch (e) {
      console.error('Create type failed:', e);
    }
  }

  // ==================== 页面导航 ====================

  /**
   * 返回上一页
   */
  goBack(): void {
    HMRouterMgr.pop();
  }

  /**
   * 保存并返回（处理导航逻辑）
   */
  async handleSave(): Promise<void> {
    const ok = await this.save();
    if (ok) {
      HMRouterMgr.pop();
    }
  }

  /**
   * 关闭新建类型弹窗
   */
  dismissAddTypeDialog(): void {
    this.showAddTypeDialog = false;
    this.newTypeLabel = '';
  }

  /**
   * 解析 extra JSON 字段
   */
  private parseExtra(extra: string): void {
    try {
      const obj = JSON.parse(extra) as CollectionExtra;
      this.wordPinyin = obj.pinyin || '';
      this.wordExplanation = obj.explanation || '';
      this.textSource = obj.source || '';
      this.textAuthor = obj.author || '';
      this.customDesc = obj.desc || '';
      // deadline
      if (obj.deadline && obj.deadline > 0) {
        this.setDeadline(obj.deadline);
      }
      // subItems
      if (obj.subItems && Array.isArray(obj.subItems)) {
        this.subItems = obj.subItems.map((s: CollectionSubItem): CollectionSubItem => {
          return { text: s.text || '', completed: s.completed || false };
        });
      }
    } catch {
      // ignore
    }
  }

  /**
   * 构建 extra JSON 字符串
   */
  private buildExtra(): string {
    let base: CollectionExtra = {};
    switch (this.itemType) {
      case 'word':
        base = {
          pinyin: this.wordPinyin,
          explanation: this.wordExplanation
        };
        break;
      case 'sentence':
      case 'quote':
        base = {
          source: this.textSource,
          author: this.textAuthor
        };
        break;
      // 知识点及所有自定义类型统一存 desc
      default:
        base = {
          desc: this.customDesc
        };
        break;
    }
    // 通用字段：deadline + subItems
    if (this.deadline > 0) {
      base.deadline = this.deadline;
    }
    if (this.subItems.length > 0) {
      base.subItems = this.subItems;
    }
    return JSON.stringify(base);
  }

  /**
   * 当前选中的类型是否内置
   */
  isCurrentBuiltIn(): boolean {
    for (let i = 0; i < this.types.length; i++) {
      const t = this.types[i];
      if (t.value === this.itemType) {
        return t.isBuiltIn === 1;
      }
    }
    return false;
  }

  /**
   * 获取标题占位文本
   */
  getTitlePlaceholder(): string {
    switch (this.itemType) {
      case 'word': return '请输入词语';
      case 'sentence': return '输入句子首句或标题';
      case 'quote': return '输入台词首句或标题';
      case 'knowledge': return '输入知识点名称';
      default: return '请输入标题';
    }
  }

  /**
   * 获取内容占位文本
   */
  getContentPlaceholder(): string {
    switch (this.itemType) {
      case 'word': return '可填入完整释义或备注';
      case 'sentence': return '请输入完整句子';
      case 'quote': return '请输入完整台词';
      case 'knowledge': return '请输入知识点详细内容';
      default: return '请输入内容';
    }
  }
}
