/**
 * 路由参数类型
 * 用于编辑页面的路由传参
 */
export interface EditPageParams {
  /** 实体 id */
  id: number;
  /** 默认标签（逗号分隔），新建时预选 */
  defaultTag?: string;
}
