/**
 * 收藏编辑 ViewModel
 * 管理收藏编辑页的状态和业务逻辑
 */
import { Collection, CollectionTypeItem, CollectionExtra, EditPageParams } from 'core.model';
import { CollectionRepository } from '../repository/CollectionRepository';
import { CollectionTypeRepository } from '../repository/CollectionTypeRepository';
import { DateUtil } from 'core.util';

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

  private collectionRepo: CollectionRepository = new CollectionRepository();
  private typeRepo: CollectionTypeRepository = new CollectionTypeRepository();

  /**
   * 初始化（根据路由参数判断新增/编辑）
   */
  async init(params: EditPageParams | undefined): Promise<void> {
    await this.loadTypes();
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
      if (this.isEdit) {
        const item = await this.collectionRepo.queryById(this.itemId);
        if (item) {
          item.type = this.itemType;
          item.title = this.title;
          item.content = this.content;
          item.extra = this.buildExtra();
          item.tag = this.tag;
          await this.collectionRepo.update(item);
        }
      } else {
        const collection = new Collection();
        collection.type = this.itemType;
        collection.title = this.title;
        collection.content = this.content;
        collection.extra = this.buildExtra();
        collection.tag = this.tag;
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
    } catch {
      // ignore
    }
  }

  /**
   * 构建 extra JSON 字符串
   */
  private buildExtra(): string {
    switch (this.itemType) {
      case 'word':
        return JSON.stringify({
          pinyin: this.wordPinyin,
          explanation: this.wordExplanation
        });
      case 'sentence':
      case 'quote':
        return JSON.stringify({
          source: this.textSource,
          author: this.textAuthor
        });
      // 知识点及所有自定义类型统一存 desc
      default:
        return JSON.stringify({
          desc: this.customDesc
        });
    }
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
