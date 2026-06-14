Answer:
**Layout: The Choice Between Pagination and Continuous Scroll**
An excellent reading UX does not force a single layout on the user; instead, it 
provides adaptable modes. Research shows that while continuous scrolling can 
increase reading speed and fluidity for web-savvy users [1, 2], dynamic 
pagination provides a sense of achievement, reduces disorientation, and mimics 
the comfortable mental model of a physical book [3-5]. Because users have highly
subjective preferences, offering the choice between both is the gold standard 
[6, 7]. 
*   **epub.js** supports both a default paginated view and a continuous 
"scrolled-doc" flow that seamlessly loads offscreen sections [8, 9]. 
*   **Koodo Reader** offers dynamic options including single-column, two-column,
and continuous scrolling layouts [10]. 
*   **Readest** explicitly allows users to switch between scroll and page view 
modes, and also features a "Parallel Read" split-screen view for reading two 
documents simultaneously [11].
*   **Thorium Reader** (via Readium CSS) utilizes reference stylesheets 
meticulously designed to support both paged and scrolled views for EPUBs [12].

**Typography: Optimal Line Length and Spacing**
Typography is arguably the most impactful readability decision [13]. A core UX 
rule is maintaining an **optimal line length (measure) of 50–75 characters per 
line (CPL)**, with 66 CPL being the ideal target to prevent eye strain and 
tracking fatigue [14-16]. To complement this, **line height should generally be 
set to 150% (1.5)** of the font size [17-19]. 
*   **Koodo Reader** allows deep customization, letting users adjust font size, 
font family, line-spacing, paragraph spacing, and margins to achieve their 
optimal CPL [10]. 
*   **Readest** provides similar font and layout customizations, and uniquely 
offers **code syntax highlighting** for reading software manuals [11]. It also 
provides visual focus aids like a reading ruler and paragraph-by-paragraph 
reading modes [11].
*   **Foliate** improves typographic rhythm by supporting **auto-hyphenation** 
(using language-specific hyphenation rules) [20].

**Navigation: Table of Contents and Progress Tracking**
Orientation within a long document is crucial, as readers must build a 
"structure map" in their working memory to avoid getting lost [21]. 
*   **Thorium Reader** builds in structural support by allowing users to 
navigate via a Table of Contents (TOC), a dedicated page list, and custom 
bookmarks [22].
*   Visible progress indicators (like progress bars or "Page X of Y" counters) 
provide critical visual feedback, satisfying the user's need to know how far 
along they are in the text [23, 24]. 

**Color Themes: Glare Reduction and Accessibility**
Color themes dictate visual comfort, particularly for long reading sessions. 
Pure white backgrounds can cause glare and visual stress; experts and 
dyslexia-friendly guidelines recommend using soft cream, off-white, or dark 
themes [25, 26]. 
*   **Koodo Reader** features a dedicated Night Mode, theme colors, and 
fine-grained controls to adjust background color, text color, and screen 
brightness [10].
*   **Readest** also allows full customization of theme modes and colors to 
personalize the visual experience [11].

**Highlight and Annotation UI: Context and Quick Actions**
Active reading requires seamless tools for externalizing thoughts [27]. A major 
UX pitfall in digital reading is that viewing highlights as an isolated list 
removes them from the body of the text, causing users to lose important 
contextual connections [28, 29]. An excellent annotation UI must allow for 
in-line, frictionless markup that keeps the user in the flow of learning [30].
*   **Readest** supports bookmarks, notes, and an **"instant mode"** designed 
for quicker annotation interactions so the reader's focus isn't broken [11].
*   **Koodo Reader** provides a robust visual vocabulary for markup, offering 
text highlighting, underlining, boldness, italics, and shadow [10]. Crucially, 
it prevents annotations from being trapped in the reader by allowing one-click 
exports (CSV, Markdown, HTML, PDF) and **syncing notes and highlights directly 
to knowledge management tools** like Readwise, Notion, and Obsidian [10].

Conversation: 00000000-0000-0000-0000-000000000000 (turn 1)
