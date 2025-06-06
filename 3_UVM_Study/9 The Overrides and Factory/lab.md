![image](https://github.com/user-attachments/assets/fd2d06b8-32b9-44e5-94f7-c269e81c4ae2)
1. 新增factory使用
2. 使用base class & 延伸class
3. 使用type override來動態改變packet的產生
4. 使用configuration來控制UVC topology

# 實作
只要在test level的build phase使用set_type_override_by_type(src_type::get_type(), des_type::get_type())即可  
|Sequence|Test|Log|
|---|---|---|
|![image](https://github.com/user-attachments/assets/0b1e25d8-64f7-4b39-a2fa-3e589992e4c8)|![image](https://github.com/user-attachments/assets/836643a8-f481-48c5-ac23-9ac117463da0)|![image](https://github.com/user-attachments/assets/165681c4-b598-42ec-8692-749e2e84f73e)
|
