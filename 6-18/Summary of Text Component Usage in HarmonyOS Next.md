# Summary of Text Component Usage in HarmonyOS Next

#### I. Basic Information

The Text component has been supported since API Version 7. It can contain subcomponents such as Span, ImageSpan, SymbolSpan, and ContainerSpan. The interface is `Text(content?: string | Resource, value?: TextOptions)`. Support in ArkTS cards was added in API version 9, and support in meta services was added in API version 11. System capability is `SystemCapability.ArkUI.ArkUI.Full`.

#### II. Parameter Description

1. **content**: Text content, which can be a string or resource. If it contains Span subcomponents and no attribute string is set, Span content will be displayed, and Text component styles won't take effect. Default value is `' '`.
2. **value (11+)**: Text component initialization options.

#### III. Attribute Introduction

1. **textAlign**: Sets horizontal alignment of text paragraphs (available in ArkTS cards from API v9, in meta services from API v11). Parameter type is `TextAlign`, default is `TextAlign.Start`. Use `align` to control vertical position. `wordBreak` must be set when using `TextAlign.JUSTIFY`.

2. **textOverflow**: Sets display method for overflow text (available in ArkTS cards from API v9, in meta services from API v11). Parameter type is `{overflow: TextOverflow}`, default is `{overflow: TextOverflow.Clip}`. Truncation is character-based. Different overflow values have different effects when combined with `maxLines`, `copyOption`, etc. Special cases exist for `TextOverflow.MARQUEE` mode.

3. **maxLines**: Sets maximum number of text lines (available in ArkTS cards from API v9, in meta services from API v11). Parameter type is `number`.

4. **lineHeight**: Sets text line height (available in ArkTS cards from API v9, in meta services from API v11). Parameter type is `number | string | Resource`.

5. **decoration (12+)**: Sets text decoration line style and color (available in ArkTS cards from API v9, in meta services from API v11). Parameter type is `DecorationStyleInterface`.

6. **baselineOffset**: Sets text baseline offset (available in ArkTS cards from API v9, in meta services from API v11). Parameter type is `number | string`, default is `0`.

7. **letterSpacing**: Sets character spacing (available in ArkTS cards from API v9, in meta services from API v11). Parameter type is `number | string`.

8. **minFontSize**: Sets minimum display font size (available in ArkTS cards from API v9, in meta services from API v11). Must be used with other attributes. Parameter type is `number | string | Resource`.

9. **maxFontSize**: Sets maximum display font size (available in ArkTS cards from API v9, in meta services from API v11). Must be used with other attributes. Parameter type is `number | string | Resource`.

10. **textCase**: Sets text capitalization (available in ArkTS cards from API v9, in meta services from API v11). Parameter type is `TextCase`, default is `TextCase.Normal`.

11. **fontColor**: Sets font color (available in ArkTS cards from API v9, in meta services from API v11). Parameter type is `ResourceColor`.

12. **fontSize**: Sets font size (available in ArkTS cards from API v9, in meta services from API v11). Parameter type is `Resource | number | string`. Default font size is 16fp. Percentage strings not supported.

13. **fontStyle**: Sets font style (available in ArkTS cards from API v9, in meta services from API v11). Parameter type is `FontStyle`, default is `FontStyle.Normal`.

14. **fontWeight**: Sets font weight (available in ArkTS cards from API v9, in meta services from API v11). Parameter type is `FontWeight | number | string`, default is `FontWeight.Normal`.

15. **fontFamily**: Sets font list (available in ArkTS cards from API v9, in meta services from API v11). Parameter type is `Resource | string`. Default font is `'HarmonyOS Sans'`.

16. **copyOption (9+)**: Enables text copy/paste (available in ArkTS cards from API v9, in meta services from API v11). Parameter type is `CopyOptions`, default is `CopyOptions.None`. Long-press on text in cards doesn't show menu.

17. **draggable (9+)**: Enables text drag selection (available in meta services from API v11). Parameter type is `boolean`, default is `false`. Must be used with `CopyOptions`.

18. **font (10+)**: Sets text style (available in meta services from API v11). Parameter type is `Font`.

19. **textShadow (10+)**: Sets text shadow effect (available in ArkTS cards from API v10, in meta services from API v11). Parameter type is `ShadowOptions | Array<ShadowOptions>` (11+).

20. **heightAdaptivePolicy (10+)**: Sets text height adaptation method (available in meta services from API v11). Parameter type is `TextHeightAdaptivePolicy`, default is `TextHeightAdaptivePolicy.MAX_LINES_FIRST`.

21. **textIndent (10+)**: Sets first line indent (available in meta services from API v11). Parameter type is `Length`, default is `0`.

22. **wordBreak (11+)**: Sets line breaking rules (available in meta services from API v11). Parameter type is `WordBreak`, default is `WordBreak.BREAK_WORD`. Can be combined with specific attributes for letter-based English word truncation.

23. **selection (11+)**: Sets selection area (available in meta services from API v11). Parameters are `selectionStart: number, selectionEnd: number`. Multiple activation constraints apply.

24. **ellipsisMode (11+)**: Sets ellipsis position (available in meta services from API v12). Parameter type is `EllipsisMode`, default is `EllipsisMode.END`. Must be used with specific attributes.

25. **enableDataDetector (11+)**: Enables special entity recognition (available in meta services from API v11). Parameter type is `boolean`. Depends on device's underlying text recognition capabilities. Different styles and functionalities exist under different settings. Doesn't work in `TextOverflow.MARQUEE` mode.

    Code Example

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
          // Horizontal text alignment settings
          // Single line text
          Text('textAlign').fontSize(9).fontColor(0xCCCCCC)
          Text('TextAlign set to Center.')
            .style(TextAlign.Center)
          Text('TextAlign set to Start.')
            .style(TextAlign.Start)
          Text('TextAlign set to End.')
            .style(TextAlign.End)
    
          // Multi-line text
          Text('This is the text content with textAlign set to Center.')
            .style(TextAlign.Center)
          Text('This is the text content with textAlign set to Start.')
            .style(TextAlign.Start)
          Text('This is the text content with textAlign set to End.')
            .style(TextAlign.End)
    
    
          // Display method for overflow text
          Text('TextOverflow+maxLines').fontSize(9).fontColor(0xCCCCCC)
          // Content truncated beyond maxLines
          Text('This is the setting of textOverflow to Clip text content This is the setting of textOverflow to None text content. This is the setting of textOverflow to Clip text content This is the setting of textOverflow to None text content.')
            .textOverflow({ overflow: TextOverflow.Clip })
            .maxLines(1)
            .style(TextAlign.Start)
    
          // Ellipsis displayed beyond maxLines
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