/**
 * 收藏列表页 ViewModel
 * 管理收藏列表数据加载、类型筛选、展开/删除等业务逻辑
 */
import { Collection } from 'core.model';
import { CollectionRepository } from '../repository/CollectionRepository';
import { CollectionTypeRepository } from '../repository/CollectionTypeRepository';

/** 类型筛选配置 */
export interface TypeOption {
  label: string;
  value: string;
}

@Observed
export class CollectionPageViewModel {
  collections: Collection[] = [];
  typeOptions: TypeOption[] = [];
  selectedType: string = '';
  expandedId: number = -1;

  private collectionRepo: CollectionRepository = new CollectionRepository();
  private typeRepo: CollectionTypeRepository = new CollectionTypeRepository();

  async loadTypes(): Promise<void> {
    try {
      const typeList = await this.typeRepo.queryAll();
      const list: TypeOption[] = [
        { label: '全部', value: '' }
      ];
      for (let i = 0; i < typeList.length; i++) {
        const t = typeList[i];
        list.push({
          label: t.label,
          value: t.name,
        });
      }
      this.typeOptions = list;
    } catch (e) {
      console.error('Load types failed:', e);
    }
  }

  async loadCollections(): Promise<void> {
    try {
      if (this.selectedType) {
        this.collections = await this.collectionRepo.queryByType(this.selectedType);
      } else {
        this.collections = await this.collectionRepo.queryAll();
      }
    } catch (e) {
      console.error('Load collections failed:', e);
    }
  }

  async deleteCollection(id: number): Promise<void> {
    try {
      await this.collectionRepo.delete(id);
      await this.loadCollections();
    } catch (e) {
      console.error('Delete collection failed:', e);
    }
  }

  /** 根据 type name 获取显示标签 */
  getTypeLabel(type: string): string {
    for (let i = 0; i < this.typeOptions.length; i++) {
      if (this.typeOptions[i].value === type) {
        return this.typeOptions[i].label;
      }
    }
    return type;
  }

  /** 解析 extra JSON 获取扩展信息 */
  getExtraText(extra: string, type: string): string {
    try {
      const obj: Record<string, string> = JSON.parse(extra) as Record<string, string>;
      switch (type) {
        case 'word':
          return (obj.pinyin ? `拼音：${obj.pinyin}` : '') +
                 (obj.explanation ? `\n释义：${obj.explanation}` : '');
        case 'sentence':
        case 'quote':
          return (obj.source ? `—— ${obj.source}` : '') +
                 (obj.author ? ` · ${obj.author}` : '');
        default:
          return obj.desc || '';
      }
    } catch {
      return '';
    }
  }
}
