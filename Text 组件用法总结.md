# 鸿蒙 Next 中 Text 组件用法总结

#### 一、基本信息

Text 组件从 API Version 7 开始支持。可包含 Span、ImageSpan、SymbolSpan 和 ContainerSpan 子组件，接口为 Text (content?: string | Resource, value?: TextOptions)。从 API version 9 开始支持在 ArkTS 卡片中使用，从 API version 11 开始支持在元服务中使用，系统能力为 SystemCapability.ArkUI.ArkUI.Full。

#### 二、参数说明

1. **content**：文本内容，可为字符串或资源。若包含子组件 Span 且未设置属性字符串，则显示 Span 内容，此时 text 组件样式不生效，默认值为 ' '。
2. **value（11 +）**：文本组件初始化选项。

#### 三、属性介绍

1. **textAlign**：设置文本段落在水平方向的对齐方式（从 API version 9 在 ArkTS 卡片、API version 11 在元服务中可用），参数类型为 TextAlign，默认值为 TextAlign.Start。通过 align 属性控制垂直方向位置，结合 textAlign 控制水平位置，textAlign 为 TextAlign.JUSTIFY 时需设置 wordBreak 属性。

2. **textOverflow**：设置文本超长时的显示方式（从 API version 9 在 ArkTS 卡片、API version 11 在元服务中可用），参数类型为 {overflow: TextOverflow}，默认值为 {overflow: TextOverflow.Clip}。截断按字截断，不同 overflow 值与 maxLines、copyOption 等属性有不同的配合效果，TextOverflow.MARQUEE 模式下有特殊情况。

3. **maxLines**：设置文本最大行数（从 API version 9 在 ArkTS 卡片、API version 11 在元服务中可用），参数类型为 number。

4. **lineHeight**：设置文本行高（从 API version 9 在 ArkTS 卡片、API version 11 在元服务中可用），参数类型为 number | string | Resource。

5. **decoration（12 +）**：设置文本装饰线样式及其颜色（从 API version 9 在 ArkTS 卡片、API version 11 在元服务中可用），参数类型为 DecorationStyleInterface。

6. **baselineOffset**：设置文本基线偏移量（从 API version 9 在 ArkTS 卡片、API version 11 在元服务中可用），参数类型为 number | string，默认值为 0。

7. **letterSpacing**：设置文本字符间距（从 API version 9 在 ArkTS 卡片、API version 11 在元服务中可用），参数类型为 number | string。

8. **minFontSize**：设置文本最小显示字号（从 API version 9 在 ArkTS 卡片、API version 11 在元服务中可用），需配合其他属性使用，参数类型为 number | string | Resource。

9. **maxFontSize**：设置文本最大显示字号（从 API version 9 在 ArkTS 卡片、API version 11 在元服务中可用），需配合其他属性使用，参数类型为 number | string | Resource。

10. **textCase**：设置文本大小写（从 API version 9 在 ArkTS 卡片、API version 11 在元服务中可用），参数类型为 TextCase，默认值为 TextCase.Normal。

11. **fontColor**：设置字体颜色（从 API version 9 在 ArkTS 卡片、API version 11 在元服务中可用），参数类型为 ResourceColor。

12. **fontSize**：设置字体大小（从 API version 9 在 ArkTS 卡片、API version 11 在元服务中可用），参数类型为 Resource | number | string，默认字体大小 16fp，不支持百分比字符串。

13. **fontStyle**：设置字体样式（从 API version 9 在 ArkTS 卡片、API version 11 在元服务中可用），参数类型为 FontStyle，默认值为 FontStyle.Normal。

14. **fontWeight**：设置文本字体粗细（从 API version 9 在 ArkTS 卡片、API version 11 在元服务中可用），参数类型为 FontWeight | number | string，默认值为 FontWeight.Normal。

15. **fontFamily**：设置字体列表（从 API version 9 在 ArkTS 卡片、API version 11 在元服务中可用），参数类型为 Resource | string，默认字体 'HarmonyOS Sans'。

16. **copyOption（9 +）**：设置组件是否支持文本可复制粘贴（从 API version 9 在 ArkTS 卡片、API version 11 在元服务中可用），参数类型为 CopyOptions，默认值为 CopyOptions.None。卡片长按文本无菜单弹出。

17. **draggable（9 +）**：设置选中文本拖拽效果（从 API version 11 在元服务中可用），参数类型为 boolean，默认值为 false，需配合 CopyOptions 使用。

18. **font（10 +）**：设置文本样式（从 API version 11 在元服务中可用），参数类型为 Font。

19. **textShadow（10 +）**：设置文字阴影效果（从 API version 10 在 ArkTS 卡片、API version 11 在元服务中可用），参数类型为 ShadowOptions | Array<ShadowOptions>（11 +）。

20. **heightAdaptivePolicy（10 +）**：设置文本自适应高度的方式（从 API version 11 在元服务中可用），参数类型为 TextHeightAdaptivePolicy，默认值为 TextHeightAdaptivePolicy.MAX_LINES_FIRST。

21. **textIndent（10 +）**：设置首行文本缩进（从 API version 11 在元服务中可用），参数类型为 Length，默认值为 0。

22. **wordBreak（11 +）**：设置断行规则（从 API version 11 在元服务中可用），参数类型为 WordBreak，默认值为 WordBreak.BREAK_WORD，可与特定属性组合实现英文单词按字母截断。

23. **selection（11 +）**：设置选中区域（从 API version 11 在元服务中可用），参数类型为 selectionStart: number, selectionEnd: number，有多种生效条件限制。

24. **ellipsisMode（11 +）**：设置省略位置（从 API version 12 在元服务中可用），参数类型为 EllipsisMode，默认值为 EllipsisMode.END，需配合特定属性使用。

25. **enableDataDetector（11 +）**：设置是否进行文本特殊实体识别（从 API version 11 在元服务中可用），参数类型为 boolean。依赖设备底层文本识别能力，有不同设置下的样式变化和功能差异，TextOverflow.MARQUEE 模式下功能不生效。

    代码示例

    ```js
    // xxx.ets
    @Extend(Text)
    function style(TextAlign: TextAlign) {
      .textAlign(TextAlign)
      .fontSize(12)
      .border({ width: 1 })
      .padding(10)
      .width('100%')
    }
    
    @Entry
    @Component
    struct TextExample1 {
      build() {
        Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start, justifyContent: FlexAlign.SpaceBetween }) {
          // 文本水平方向对齐方式设置
          // 单行文本
          Text('textAlign').fontSize(9).fontColor(0xCCCCCC)
          Text('TextAlign set to Center.')
            .style(TextAlign.Center)
          Text('TextAlign set to Start.')
            .style(TextAlign.Start)
          Text('TextAlign set to End.')
            .style(TextAlign.End)
    
          // 多行文本
          Text('This is the text content with textAlign set to Center.')
            .style(TextAlign.Center)
          Text('This is the text content with textAlign set to Start.')
            .style(TextAlign.Start)
          Text('This is the text content with textAlign set to End.')
            .style(TextAlign.End)
    
    
          // 文本超长时显示方式
          Text('TextOverflow+maxLines').fontSize(9).fontColor(0xCCCCCC)
          // 超出maxLines截断内容展示
          Text('This is the setting of textOverflow to Clip text content This is the setting of textOverflow to None text content. This is the setting of textOverflow to Clip text content This is the setting of textOverflow to None text content.')
            .textOverflow({ overflow: TextOverflow.Clip })
            .maxLines(1)
            .style(TextAlign.Start)
    
          // 超出maxLines展示省略号
          Text('This is set textOverflow to Ellipsis text content This is set textOverflow to Ellipsis text content.')
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(1)
            .style(TextAlign.Start)
    
          Text('lineHeight').fontSize(9).fontColor(0xCCCCCC)
          Text('This is the text with the line height set. This is the text with the line height set.')
            .style(TextAlign.Start)
          Text('This is the text with the line height set. This is the text with the line height set.')
            .style(TextAlign.Start)
            .lineHeight(20)
        }.height(600).width(340).padding({ left: 35, right: 35, top: 35 })
      }
    }
    ```

    