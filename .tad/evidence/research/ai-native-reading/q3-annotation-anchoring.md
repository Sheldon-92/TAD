Answer:
**How Robust Annotation Anchoring Models Work**

Robust annotation systems anchor highlights to documents using models that 
describe the exact segment of a resource, ensuring the highlight survives even 
if the document's presentation changes. According to the W3C Web Annotation Data
Model, this is achieved using **Selectors**, which describe how to determine the
segment of interest from a source resource [1]. 

Here is how the specific anchoring mechanisms function based on the provided 
sources:

*   **Text Quote Selector:** This method anchors a highlight by copying the 
exact text being selected and pairing it with a snippet of text immediately 
before it (**prefix**) and immediately after it (**suffix**) [2, 3]. This allows
the system to distinguish between multiple identical words in a document. To 
ensure robustness, the text must be normalized (e.g., removing HTML/XML tags and
replacing character entities) before it is recorded, meaning the anchor relies 
on the logical text rather than the underlying code [4]. 
*   **Text Position Selector:** This method describes a range of text by 
recording the exact integer start and end character positions in the text stream
(e.g., start at character 4, end at character 7) [5, 6]. 
*   **EPUB CFI (Canonical Fragment Identifier):** EPUB CFIs act as **Fragment 
Selectors**, conforming to specific semantic structures defined by the EPUB3 
specification [7]. They define a path to a specific location within the packaged
XML/HTML files of an EPUB document (e.g., `epubcfi(/6/4!/4/10/3:10)`) [7].
*   **Hypothesis Anchoring:** While the provided sources include the GitHub 
repository for the Hypothesis client (describing it as a browser-based web 
annotation tool) [8], *please note that the sources do not detail the internal, 
proprietary matching algorithms Hypothesis uses.* However, Hypothesis is built 
upon the W3C Web Annotation standard and utilizes combinations of the 
aforementioned Text Quote and Text Position selectors to find text dynamically 
in the browser. *(Note: The specifics of Hypothesis's "fuzzy matching" logic are
outside the provided sources and may require independent verification).*

***

**Recommended Approach for Custom HTML Readers with Regenerated HTML**

If your custom reader stores annotations in a separate data file and needs to 
re-attach them to regenerated HTML, relying on just one type of selector is 
risky. The **recommended approach is to use "Refinement of Selection" (chaining 
selectors)** alongside **State tracking** [9-11]. 

1.  **Chaining Selectors (Refinement):** You should capture multiple layers of 
location data by having one selector refine another using the `refinedBy` 
relationship [12]. For example, you can use a Fragment or XPath Selector to 
identify the specific paragraph element, and then use a **Text Quote Selector** 
to identify the exact phrase within that paragraph [10, 12]. 
2.  **Using Range Selectors:** For selections that cross over internal HTML 
boundaries (like highlighting across multiple paragraph tags), use a **Range 
Selector**. This uses a `startSelector` and an `endSelector` (such as two 
XPaths) to accurately identify the beginning and end points of a vast selection 
independently [13, 14].
3.  **Recording Resource State:** Because regenerated HTML can change, you 
should record the **State** of the resource (such as a `TimeState` or 
`HttpRequestState`). This tells the client exactly which representation or 
version of the document the annotation was originally attached to [11, 15].

***

**Failure Modes of Anchoring Approaches**

When re-attaching annotations to regenerated HTML, you will encounter specific 
failure modes depending on the selector used:

*   **Text Position Selectors are "very brittle":** Because they rely on exact 
character counts (index numbers), any minor edits to the text or dynamically 
transcluded content injected into the HTML will shift the character positions, 
completely breaking the highlight [9].
*   **XPath and CSS Selectors are vulnerable to DOM shifts:** These selectors 
map the exact structural path to an element. If your HTML generation process 
changes the DOM structure, the path will break. Additionally, HTML5 parsers in 
browsers sometimes automatically inject missing elements (such as `<tbody>` 
inside tables); if your XPath does not account for this, the anchor will fail to
attach to the rendered page [16].
*   **Text Quote Selectors can trigger multiple matches:** If the exact same 
quote, prefix, and suffix appear more than once in the regenerated HTML, the 
user agent will fail to isolate the single intended highlight and will instead 
treat the selection as matching *all* identical text sequences [4]. 
*   **Fragment Identifiers lack precision:** Relying solely on standard HTML 
fragment IDs (e.g., `#section1`) fails for granular highlighting because 
fragments cannot describe an arbitrary span or range of text within the block 
[17].

Conversation: 00000000-0000-0000-0000-000000000000 (turn 1)
