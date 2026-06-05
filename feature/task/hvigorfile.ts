import { harPlugin } from '@hadss/hmrouter-plugin/dist/Index';
import { harTasks } from '@ohos/hvigor-ohos-plugin';

export default {
  system: harTasks,
  plugins: [harPlugin()]
}
