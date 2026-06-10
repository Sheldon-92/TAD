# AI Integration & Application Skill

---
title: "AI Integration & Application"
version: "3.0"
last_updated: "2026-01-07"
tags: [ai, llm, rag, integration, evaluation]
domains: [ai]
level: intermediate
estimated_time: "60min"
prerequisites: []
sources:
  - "OpenAI/Anthropic API Docs"
  - "RAG Best Practices"
enforcement: recommended
tad_gates: [Gate2_Design, Gate3_Implementation_Quality]
---

> 综合自 AI 应用开发最佳实践和 LLM 应用架构，已适配 TAD 框架

## TL;DR Quick Checklist

```
1. [ ] 集成计划：目标/接口/数据/安全/评测
2. [ ] 工具评估：成本/性能/质量/合规
3. [ ] 观测：日志/指标/追踪/失败样例库
4. [ ] 评测：黄金集/鲁棒性/安全性/偏见
5. [ ] 产出：集成计划/工具评估/风险清单
```

**Red Flags:** 黑盒集成、无监控、无评测、无回退策略

## 触发条件

当用户需要集成 AI/LLM 能力、构建 RAG 系统、设计 AI 工作流或开发智能应用时，自动应用此 Skill。

---

## 核心能力

```
AI 应用工具箱
├── LLM 集成
│   ├── API 调用
│   ├── 流式响应
│   └── 错误处理
├── RAG 系统
│   ├── 文档处理
│   ├── 向量存储
│   └── 检索策略
├── Embedding
│   ├── 文本向量化
│   ├── 语义搜索
│   └── 相似度计算
└── AI 工作流
    ├── Chain 设计
    ├── Agent 架构
    └── 评估优化
```

---

## LLM API 集成

### OpenAI API 集成

```python
"""OpenAI API 集成示例"""

import openai
from openai import OpenAI

# 初始化客户端
client = OpenAI(api_key="your-api-key")

# 基础调用
def chat_completion(messages: list, model: str = "gpt-4") -> str:
    """基础对话补全"""
    response = client.chat.completions.create(
        model=model,
        messages=messages,
        temperature=0.7,
        max_tokens=1000
    )
    return response.choices[0].message.content

# 流式响应
def stream_chat(messages: list, model: str = "gpt-4"):
    """流式对话，逐步返回结果"""
    stream = client.chat.completions.create(
        model=model,
        messages=messages,
        stream=True
    )

    for chunk in stream:
        if chunk.choices[0].delta.content:
            yield chunk.choices[0].delta.content

# Function Calling
def chat_with_tools(messages: list, tools: list):
    """带工具调用的对话"""
    response = client.chat.completions.create(
        model="gpt-4",
        messages=messages,
        tools=tools,
        tool_choice="auto"
    )

    message = response.choices[0].message

    if message.tool_calls:
        # 处理工具调用
        for tool_call in message.tool_calls:
            function_name = tool_call.function.name
            arguments = json.loads(tool_call.function.arguments)
            # 执行工具并返回结果
            result = execute_tool(function_name, arguments)
            messages.append(message)
            messages.append({
                "role": "tool",
                "tool_call_id": tool_call.id,
                "content": str(result)
            })
        # 继续对话
        return chat_with_tools(messages, tools)

    return message.content
```

### Anthropic Claude API

```python
"""Anthropic Claude API 集成示例"""

import anthropic

client = anthropic.Anthropic(api_key="your-api-key")

# 基础调用
def claude_chat(messages: list, system: str = None) -> str:
    """Claude 对话"""
    response = client.messages.create(
        model="claude-3-opus-20240229",
        max_tokens=1024,
        system=system,
        messages=messages
    )
    return response.content[0].text

# 流式响应
def claude_stream(messages: list, system: str = None):
    """Claude 流式响应"""
    with client.messages.stream(
        model="claude-3-opus-20240229",
        max_tokens=1024,
        system=system,
        messages=messages
    ) as stream:
        for text in stream.text_stream:
            yield text

# 带工具的调用
def claude_with_tools(messages: list, tools: list):
    """Claude 工具调用"""
    response = client.messages.create(
        model="claude-3-opus-20240229",
        max_tokens=1024,
        tools=tools,
        messages=messages
    )

    # 处理工具使用
    for block in response.content:
        if block.type == "tool_use":
            tool_name = block.name
            tool_input = block.input
            # 执行工具
            result = execute_tool(tool_name, tool_input)
            # 继续对话...

    return response
```

### 错误处理和重试

```python
"""API 调用错误处理"""

import time
from typing import Callable
import openai

def retry_with_exponential_backoff(
    func: Callable,
    max_retries: int = 3,
    initial_delay: float = 1,
    exponential_base: float = 2,
    errors: tuple = (openai.RateLimitError, openai.APIError)
):
    """指数退避重试装饰器"""
    def wrapper(*args, **kwargs):
        delay = initial_delay
        for i in range(max_retries):
            try:
                return func(*args, **kwargs)
            except errors as e:
                if i == max_retries - 1:
                    raise
                print(f"Error: {e}. Retrying in {delay} seconds...")
                time.sleep(delay)
                delay *= exponential_base
    return wrapper

@retry_with_exponential_backoff
def safe_chat_completion(messages: list) -> str:
    """带重试的 API 调用"""
    return chat_completion(messages)


class LLMError(Exception):
    """LLM 相关错误基类"""
    pass

class RateLimitError(LLMError):
    """速率限制错误"""
    pass

class TokenLimitError(LLMError):
    """Token 超限错误"""
    pass

def handle_llm_error(error: Exception) -> str:
    """统一错误处理"""
    if isinstance(error, openai.RateLimitError):
        return "请求过于频繁，请稍后重试"
    elif isinstance(error, openai.APIError):
        return f"API 错误: {error.message}"
    elif isinstance(error, openai.AuthenticationError):
        return "API 认证失败，请检查 API Key"
    else:
        return f"未知错误: {str(error)}"
```

---

## Outputs / Evidence / Acceptance

### Required Evidence

| Evidence Type   | Description         | Location                                      |
|-----------------|---------------------|-----------------------------------------------|
| `integration_plan` | 集成计划与架构    | `.tad/evidence/integration/plan.md`           |
| `tool_eval`        | 工具评估与对比    | `.tad/evidence/integration/tool-eval.md`      |
| `risk_register`    | 风险清单与缓解    | `.tad/evidence/integration/risks.md`          |

### Acceptance Criteria

```
[ ] 目标/接口/数据/安全清晰；评测指标合理
[ ] 工具评估客观可复现；选择理由充分
[ ] 风险与回退策略明确；监控观测到位
```

### Artifacts

| Artifact          | Path                                         |
|-------------------|----------------------------------------------|
| Integration Plan  | `.tad/evidence/integration/plan.md`          |
| Tool Evaluation   | `.tad/evidence/integration/tool-eval.md`     |
| Risk Register     | `.tad/evidence/integration/risks.md`         |

## RAG 系统架构

### 文档处理

```python
"""文档处理和分块"""

from typing import List
import tiktoken

class DocumentProcessor:
    """文档处理器"""

    def __init__(self, chunk_size: int = 500, chunk_overlap: int = 50):
        self.chunk_size = chunk_size
        self.chunk_overlap = chunk_overlap
        self.tokenizer = tiktoken.get_encoding("cl100k_base")

    def load_document(self, file_path: str) -> str:
        """加载文档"""
        if file_path.endswith('.pdf'):
            return self._load_pdf(file_path)
        elif file_path.endswith('.txt'):
            return self._load_text(file_path)
        elif file_path.endswith('.md'):
            return self._load_markdown(file_path)
        else:
            raise ValueError(f"Unsupported file type: {file_path}")

    def chunk_text(self, text: str) -> List[str]:
        """文本分块"""
        tokens = self.tokenizer.encode(text)
        chunks = []

        for i in range(0, len(tokens), self.chunk_size - self.chunk_overlap):
            chunk_tokens = tokens[i:i + self.chunk_size]
            chunk_text = self.tokenizer.decode(chunk_tokens)
            chunks.append(chunk_text)

        return chunks

    def chunk_by_separator(self, text: str, separators: List[str] = None) -> List[str]:
        """按分隔符分块 (语义分块)"""
        if separators is None:
            separators = ["\n\n", "\n", ". ", " "]

        chunks = [text]
        for separator in separators:
            new_chunks = []
            for chunk in chunks:
                if len(self.tokenizer.encode(chunk)) > self.chunk_size:
                    new_chunks.extend(chunk.split(separator))
                else:
                    new_chunks.append(chunk)
            chunks = new_chunks

        # 合并过小的块
        return self._merge_small_chunks(chunks)

    def _merge_small_chunks(self, chunks: List[str], min_size: int = 100) -> List[str]:
        """合并过小的块"""
        merged = []
        current = ""

        for chunk in chunks:
            if len(self.tokenizer.encode(current + chunk)) < min_size:
                current += chunk
            else:
                if current:
                    merged.append(current)
                current = chunk

        if current:
            merged.append(current)

        return merged
```

### 向量存储

```python
"""向量存储和检索"""

import numpy as np
from typing import List, Tuple
import chromadb
from chromadb.utils import embedding_functions

class VectorStore:
    """向量存储"""

    def __init__(self, collection_name: str = "documents"):
        self.client = chromadb.Client()
        self.embedding_fn = embedding_functions.OpenAIEmbeddingFunction(
            api_key="your-api-key",
            model_name="text-embedding-3-small"
        )
        self.collection = self.client.get_or_create_collection(
            name=collection_name,
            embedding_function=self.embedding_fn
        )

    def add_documents(self, documents: List[str], metadatas: List[dict] = None):
        """添加文档"""
        ids = [f"doc_{i}" for i in range(len(documents))]
        self.collection.add(
            documents=documents,
            metadatas=metadatas,
            ids=ids
        )

    def search(self, query: str, top_k: int = 5) -> List[Tuple[str, float]]:
        """搜索相似文档"""
        results = self.collection.query(
            query_texts=[query],
            n_results=top_k
        )

        documents = results['documents'][0]
        distances = results['distances'][0]

        return list(zip(documents, distances))

    def hybrid_search(self, query: str, top_k: int = 5) -> List[str]:
        """混合搜索 (语义 + 关键词)"""
        # 语义搜索
        semantic_results = self.search(query, top_k)

        # 关键词搜索 (BM25)
        keyword_results = self._keyword_search(query, top_k)

        # 融合排序 (RRF)
        return self._reciprocal_rank_fusion(semantic_results, keyword_results)


# 使用 Pinecone
import pinecone

class PineconeStore:
    """Pinecone 向量存储"""

    def __init__(self, index_name: str):
        pinecone.init(api_key="your-api-key", environment="your-env")
        self.index = pinecone.Index(index_name)

    def upsert(self, vectors: List[Tuple[str, List[float], dict]]):
        """插入向量"""
        self.index.upsert(vectors=vectors)

    def query(self, vector: List[float], top_k: int = 5) -> List[dict]:
        """查询相似向量"""
        results = self.index.query(
            vector=vector,
            top_k=top_k,
            include_metadata=True
        )
        return results.matches
```

### RAG Pipeline

```python
"""完整 RAG Pipeline"""

from dataclasses import dataclass
from typing import List, Optional

@dataclass
class RAGConfig:
    """RAG 配置"""
    chunk_size: int = 500
    chunk_overlap: int = 50
    top_k: int = 5
    model: str = "gpt-4"
    temperature: float = 0.7

class RAGPipeline:
    """RAG 管道"""

    def __init__(self, config: RAGConfig = None):
        self.config = config or RAGConfig()
        self.processor = DocumentProcessor(
            chunk_size=self.config.chunk_size,
            chunk_overlap=self.config.chunk_overlap
        )
        self.vector_store = VectorStore()

    def ingest(self, documents: List[str]):
        """文档摄入"""
        all_chunks = []
        all_metadata = []

        for i, doc in enumerate(documents):
            chunks = self.processor.chunk_text(doc)
            all_chunks.extend(chunks)
            all_metadata.extend([{"doc_id": i, "chunk_id": j}
                                for j in range(len(chunks))])

        self.vector_store.add_documents(all_chunks, all_metadata)

    def retrieve(self, query: str) -> List[str]:
        """检索相关文档"""
        results = self.vector_store.search(query, top_k=self.config.top_k)
        return [doc for doc, _ in results]

    def generate(self, query: str, context: List[str]) -> str:
        """生成回答"""
        context_str = "\n\n".join(context)

        prompt = f"""根据以下参考资料回答问题。如果资料中没有相关信息，请说明无法回答。

参考资料:
{context_str}

问题: {query}

回答:"""

        messages = [{"role": "user", "content": prompt}]
        return chat_completion(messages, model=self.config.model)

    def query(self, question: str) -> str:
        """完整查询流程"""
        # 1. 检索
        context = self.retrieve(question)

        # 2. 生成
        answer = self.generate(question, context)

        return answer


# 高级 RAG 技术
class AdvancedRAG(RAGPipeline):
    """高级 RAG 技术"""

    def query_expansion(self, query: str) -> List[str]:
        """查询扩展"""
        prompt = f"""为以下问题生成 3 个相关的搜索查询，用于检索更全面的信息:

问题: {query}

生成的查询 (每行一个):"""

        response = chat_completion([{"role": "user", "content": prompt}])
        queries = [query] + response.strip().split("\n")
        return queries

    def rerank(self, query: str, documents: List[str]) -> List[str]:
        """重排序检索结果"""
        prompt = f"""对以下文档按与问题的相关性排序，返回排序后的文档编号。

问题: {query}

文档:
{chr(10).join([f'{i+1}. {doc[:200]}...' for i, doc in enumerate(documents)])}

按相关性排序的文档编号 (最相关的在前):"""

        response = chat_completion([{"role": "user", "content": prompt}])
        # 解析排序结果并重排文档
        return self._parse_rerank(response, documents)

    def query_with_expansion(self, question: str) -> str:
        """带查询扩展的完整流程"""
        # 1. 查询扩展
        queries = self.query_expansion(question)

        # 2. 多查询检索
        all_docs = []
        for q in queries:
            docs = self.retrieve(q)
            all_docs.extend(docs)

        # 3. 去重
        unique_docs = list(set(all_docs))

        # 4. 重排序
        ranked_docs = self.rerank(question, unique_docs)

        # 5. 生成
        return self.generate(question, ranked_docs[:self.config.top_k])
```

---

## Embedding 应用

### 文本向量化

```python
"""文本 Embedding"""

from openai import OpenAI
import numpy as np
from typing import List

client = OpenAI()

def get_embedding(text: str, model: str = "text-embedding-3-small") -> List[float]:
    """获取文本 embedding"""
    response = client.embeddings.create(
        input=text,
        model=model
    )
    return response.data[0].embedding

def get_embeddings_batch(texts: List[str], model: str = "text-embedding-3-small") -> List[List[float]]:
    """批量获取 embeddings"""
    response = client.embeddings.create(
        input=texts,
        model=model
    )
    return [item.embedding for item in response.data]

def cosine_similarity(vec1: List[float], vec2: List[float]) -> float:
    """计算余弦相似度"""
    a = np.array(vec1)
    b = np.array(vec2)
    return np.dot(a, b) / (np.linalg.norm(a) * np.linalg.norm(b))
```

### 语义搜索

```python
"""语义搜索实现"""

class SemanticSearch:
    """语义搜索引擎"""

    def __init__(self):
        self.documents = []
        self.embeddings = []

    def index(self, documents: List[str]):
        """索引文档"""
        self.documents = documents
        self.embeddings = get_embeddings_batch(documents)

    def search(self, query: str, top_k: int = 5) -> List[Tuple[str, float]]:
        """搜索最相似的文档"""
        query_embedding = get_embedding(query)

        similarities = [
            cosine_similarity(query_embedding, doc_emb)
            for doc_emb in self.embeddings
        ]

        # 获取 top_k 结果
        indices = np.argsort(similarities)[::-1][:top_k]

        return [(self.documents[i], similarities[i]) for i in indices]


# 示例: 语义相似度聚类
from sklearn.cluster import KMeans

def cluster_documents(documents: List[str], n_clusters: int = 5) -> dict:
    """文档聚类"""
    embeddings = get_embeddings_batch(documents)

    kmeans = KMeans(n_clusters=n_clusters, random_state=42)
    labels = kmeans.fit_predict(embeddings)

    clusters = {}
    for i, label in enumerate(labels):
        if label not in clusters:
            clusters[label] = []
        clusters[label].append(documents[i])

    return clusters
```

---

## AI 工作流设计

### Chain 模式

```python
"""LLM Chain 设计模式"""

from abc import ABC, abstractmethod
from typing import Any, Dict

class BaseChain(ABC):
    """Chain 基类"""

    @abstractmethod
    def run(self, input: Dict[str, Any]) -> Dict[str, Any]:
        pass

class SequentialChain:
    """顺序执行的 Chain"""

    def __init__(self, chains: List[BaseChain]):
        self.chains = chains

    def run(self, input: Dict[str, Any]) -> Dict[str, Any]:
        result = input
        for chain in self.chains:
            result = chain.run(result)
        return result

class SummarizeChain(BaseChain):
    """摘要 Chain"""

    def run(self, input: Dict[str, Any]) -> Dict[str, Any]:
        text = input["text"]
        prompt = f"请总结以下文本:\n\n{text}\n\n摘要:"
        summary = chat_completion([{"role": "user", "content": prompt}])
        return {**input, "summary": summary}

class TranslateChain(BaseChain):
    """翻译 Chain"""

    def __init__(self, target_lang: str = "English"):
        self.target_lang = target_lang

    def run(self, input: Dict[str, Any]) -> Dict[str, Any]:
        text = input.get("summary") or input["text"]
        prompt = f"将以下文本翻译成{self.target_lang}:\n\n{text}"
        translation = chat_completion([{"role": "user", "content": prompt}])
        return {**input, "translation": translation}

# 使用示例
pipeline = SequentialChain([
    SummarizeChain(),
    TranslateChain("English")
])
result = pipeline.run({"text": "长文本..."})
```

### Agent 架构

```python
"""Agent 实现"""

from typing import List, Callable, Dict
import json

class Tool:
    """工具定义"""

    def __init__(self, name: str, description: str, func: Callable):
        self.name = name
        self.description = description
        self.func = func

    def to_schema(self) -> dict:
        """转换为 OpenAI function 格式"""
        return {
            "type": "function",
            "function": {
                "name": self.name,
                "description": self.description,
                "parameters": {
                    "type": "object",
                    "properties": {},  # 根据具体工具定义
                }
            }
        }

class Agent:
    """AI Agent"""

    def __init__(self, tools: List[Tool], system_prompt: str = None):
        self.tools = {tool.name: tool for tool in tools}
        self.system_prompt = system_prompt or "你是一个有用的助手。"
        self.conversation = []

    def run(self, user_input: str, max_iterations: int = 10) -> str:
        """运行 Agent"""
        self.conversation.append({"role": "user", "content": user_input})

        for _ in range(max_iterations):
            response = client.chat.completions.create(
                model="gpt-4",
                messages=[
                    {"role": "system", "content": self.system_prompt},
                    *self.conversation
                ],
                tools=[tool.to_schema() for tool in self.tools.values()],
                tool_choice="auto"
            )

            message = response.choices[0].message

            if message.tool_calls:
                # 执行工具
                self.conversation.append(message)

                for tool_call in message.tool_calls:
                    tool_name = tool_call.function.name
                    arguments = json.loads(tool_call.function.arguments)

                    result = self.tools[tool_name].func(**arguments)

                    self.conversation.append({
                        "role": "tool",
                        "tool_call_id": tool_call.id,
                        "content": str(result)
                    })
            else:
                # 返回最终结果
                return message.content

        return "达到最大迭代次数"

# 定义工具
search_tool = Tool(
    name="search",
    description="搜索互联网获取信息",
    func=lambda query: f"搜索结果: {query}"
)

calculator_tool = Tool(
    name="calculate",
    description="执行数学计算",
    func=lambda expression: eval(expression)
)

# 创建 Agent
agent = Agent(
    tools=[search_tool, calculator_tool],
    system_prompt="你是一个可以搜索和计算的助手。"
)

# 运行
result = agent.run("今天上海的天气怎么样？")
```

---

## 评估与优化

### LLM 输出评估

```python
"""LLM 输出评估"""

def evaluate_relevance(question: str, answer: str, context: str) -> dict:
    """评估答案相关性"""
    prompt = f"""评估以下答案的质量:

问题: {question}
参考资料: {context}
答案: {answer}

请从以下维度评分 (1-5分):
1. 相关性: 答案是否回答了问题
2. 准确性: 答案是否与参考资料一致
3. 完整性: 答案是否完整
4. 简洁性: 答案是否简洁明了

返回 JSON 格式:
{{"relevance": X, "accuracy": X, "completeness": X, "conciseness": X, "overall": X}}
"""

    response = chat_completion([{"role": "user", "content": prompt}])
    return json.loads(response)

def evaluate_hallucination(answer: str, context: str) -> bool:
    """检测幻觉"""
    prompt = f"""判断以下答案是否包含参考资料中没有的信息 (幻觉):

参考资料: {context}
答案: {answer}

如果答案完全基于参考资料，返回 "NO"
如果答案包含参考资料中没有的信息，返回 "YES"

只返回 YES 或 NO:"""

    response = chat_completion([{"role": "user", "content": prompt}])
    return response.strip().upper() == "YES"
```

### A/B 测试框架

```python
"""Prompt A/B 测试"""

from dataclasses import dataclass
from typing import List
import random

@dataclass
class PromptVariant:
    name: str
    template: str

class PromptABTest:
    """Prompt A/B 测试"""

    def __init__(self, variants: List[PromptVariant]):
        self.variants = variants
        self.results = {v.name: [] for v in variants}

    def run_test(self, inputs: List[str], evaluate_fn: Callable) -> dict:
        """运行测试"""
        for input_text in inputs:
            variant = random.choice(self.variants)
            prompt = variant.template.format(input=input_text)

            response = chat_completion([{"role": "user", "content": prompt}])
            score = evaluate_fn(input_text, response)

            self.results[variant.name].append(score)

        return self.get_statistics()

    def get_statistics(self) -> dict:
        """获取统计结果"""
        stats = {}
        for name, scores in self.results.items():
            if scores:
                stats[name] = {
                    "mean": np.mean(scores),
                    "std": np.std(scores),
                    "count": len(scores)
                }
        return stats
```

---

## 与 TAD 框架的集成

在 TAD 的 AI 应用开发流程中：

```
需求分析 → 架构设计 → 集成开发 → 测试评估 → 部署优化
               ↓
          [ 此 Skill ]
```

**使用场景**：
- LLM API 集成
- RAG 系统构建
- AI Agent 开发
- 语义搜索实现
- AI 应用评估

---

## 最佳实践

```
✅ 推荐
□ 使用流式响应提升用户体验
□ 实现完善的错误处理和重试
□ 对 LLM 输出进行验证和评估
□ 使用缓存减少 API 调用
□ 监控 token 使用和成本

❌ 避免
□ 忽视 API 调用限制
□ 不处理幻觉问题
□ 硬编码 API key
□ 不做 prompt 测试
□ 忽视延迟和成本优化
```

---

*此 Skill 帮助 Claude 进行专业的 AI 应用集成和开发。*
