# Knowledge Graph Skill

> 综合自知识图谱最佳实践和图数据库技术，已适配 TAD 框架

## 触发条件

当用户需要构建知识图谱、进行实体关系抽取、知识建模或图数据分析时，自动应用此 Skill。

---

## 核心能力

```
知识图谱工具箱
├── 知识建模
│   ├── 本体设计
│   ├── 模式定义
│   └── 关系建模
├── 知识抽取
│   ├── 实体识别
│   ├── 关系抽取
│   └── 属性提取
├── 图数据库
│   ├── Neo4j
│   ├── ArangoDB
│   └── Amazon Neptune
└── 知识应用
    ├── 知识问答
    ├── 推理查询
    └── 可视化
```

---

## 本体设计

### 本体建模模板

```markdown
## 知识图谱本体设计

### 领域: [领域名称]

### 核心概念 (Classes)

```yaml
Classes:
  Person:
    description: "人物实体"
    properties:
      - name: string (required)
      - birthDate: date
      - occupation: string[]

  Organization:
    description: "组织机构"
    properties:
      - name: string (required)
      - type: enum[company, school, government]
      - foundedDate: date
      - location: Location

  Location:
    description: "地理位置"
    properties:
      - name: string (required)
      - coordinates: point
      - country: string
```

### 关系定义 (Relations)

```yaml
Relations:
  WORKS_FOR:
    from: Person
    to: Organization
    properties:
      - startDate: date
      - endDate: date
      - position: string

  LOCATED_IN:
    from: Organization
    to: Location

  KNOWS:
    from: Person
    to: Person
    properties:
      - since: date
      - relationship: string
```

### 约束规则 (Constraints)

```yaml
Constraints:
  - Person.name is unique
  - Organization.name is unique within type
  - WORKS_FOR.startDate <= WORKS_FOR.endDate
```
```

---

## Neo4j Cypher 查询

### 基础操作

```cypher
// 创建节点
CREATE (p:Person {name: '张三', age: 30, occupation: '工程师'})
CREATE (c:Company {name: '科技公司', founded: 2010})

// 创建关系
MATCH (p:Person {name: '张三'})
MATCH (c:Company {name: '科技公司'})
CREATE (p)-[:WORKS_FOR {since: 2020, position: '高级工程师'}]->(c)

// 查询节点
MATCH (p:Person)
WHERE p.age > 25
RETURN p.name, p.age

// 查询关系
MATCH (p:Person)-[r:WORKS_FOR]->(c:Company)
RETURN p.name, r.position, c.name

// 路径查询
MATCH path = (p1:Person)-[:KNOWS*1..3]-(p2:Person)
WHERE p1.name = '张三' AND p2.name = '李四'
RETURN path
```

### 高级查询

```cypher
// 聚合查询
MATCH (p:Person)-[:WORKS_FOR]->(c:Company)
RETURN c.name, count(p) as employee_count
ORDER BY employee_count DESC

// 子图查询
MATCH (p:Person {name: '张三'})-[*1..2]-(related)
RETURN p, related

// 最短路径
MATCH path = shortestPath(
  (p1:Person {name: '张三'})-[*]-(p2:Person {name: '李四'})
)
RETURN path, length(path)

// 图算法 - PageRank
CALL gds.pageRank.stream('myGraph')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).name AS name, score
ORDER BY score DESC

// 社区发现
CALL gds.louvain.stream('myGraph')
YIELD nodeId, communityId
RETURN gds.util.asNode(nodeId).name AS name, communityId
ORDER BY communityId
```

### 数据导入

```cypher
// 从 CSV 导入
LOAD CSV WITH HEADERS FROM 'file:///persons.csv' AS row
CREATE (p:Person {
  id: row.id,
  name: row.name,
  age: toInteger(row.age)
})

// 批量创建关系
LOAD CSV WITH HEADERS FROM 'file:///relationships.csv' AS row
MATCH (p1:Person {id: row.from_id})
MATCH (p2:Person {id: row.to_id})
CREATE (p1)-[:KNOWS {since: date(row.since)}]->(p2)

// 使用 APOC 导入 JSON
CALL apoc.load.json('file:///data.json') YIELD value
UNWIND value.persons AS person
CREATE (p:Person) SET p = person
```

---

## 知识抽取

### 实体识别模板

```python
"""知识抽取流程"""

from typing import List, Dict, Tuple

class EntityExtractor:
    """实体抽取器"""

    def __init__(self):
        self.entity_types = {
            'PERSON': '人物',
            'ORG': '组织',
            'LOC': '地点',
            'DATE': '日期',
            'PRODUCT': '产品'
        }

    def extract_entities(self, text: str) -> List[Dict]:
        """
        从文本中抽取实体

        返回格式:
        [
            {
                'text': '张三',
                'type': 'PERSON',
                'start': 0,
                'end': 2,
                'confidence': 0.95
            }
        ]
        """
        pass

    def extract_relations(self, text: str, entities: List[Dict]) -> List[Dict]:
        """
        抽取实体间关系

        返回格式:
        [
            {
                'subject': {'text': '张三', 'type': 'PERSON'},
                'predicate': 'WORKS_FOR',
                'object': {'text': '科技公司', 'type': 'ORG'},
                'confidence': 0.88
            }
        ]
        """
        pass


class KnowledgeGraphBuilder:
    """知识图谱构建器"""

    def __init__(self, neo4j_uri: str, user: str, password: str):
        from neo4j import GraphDatabase
        self.driver = GraphDatabase.driver(neo4j_uri, auth=(user, password))

    def add_entity(self, entity: Dict):
        """添加实体到图数据库"""
        query = """
        MERGE (e:{type} {{name: $name}})
        SET e += $properties
        RETURN e
        """.format(type=entity['type'])

        with self.driver.session() as session:
            session.run(query, name=entity['name'], properties=entity.get('properties', {}))

    def add_relation(self, subject: Dict, predicate: str, object_: Dict, properties: Dict = None):
        """添加关系"""
        query = """
        MATCH (s:{s_type} {{name: $s_name}})
        MATCH (o:{o_type} {{name: $o_name}})
        MERGE (s)-[r:{predicate}]->(o)
        SET r += $properties
        RETURN r
        """.format(
            s_type=subject['type'],
            o_type=object_['type'],
            predicate=predicate
        )

        with self.driver.session() as session:
            session.run(query,
                       s_name=subject['name'],
                       o_name=object_['name'],
                       properties=properties or {})
```

### 三元组抽取模板

```markdown
## 三元组抽取指南

### 输入文本
[待抽取的文本]

### 抽取步骤

1. **识别实体**
   - 标注所有命名实体
   - 确定实体类型

2. **识别关系**
   - 找出实体间的语义关系
   - 确定关系方向

3. **构建三元组**
   - 格式: (主体, 谓语, 客体)
   - 标注置信度

### 输出格式

| 主体 | 关系 | 客体 | 置信度 |
|------|------|------|--------|
| 张三 (Person) | 就职于 | 腾讯 (Company) | 0.95 |
| 腾讯 (Company) | 总部位于 | 深圳 (Location) | 0.90 |

### 关系类型标准化

| 原文表述 | 标准化关系 |
|----------|------------|
| 就职于/工作在/任职于 | WORKS_FOR |
| 位于/坐落于/总部在 | LOCATED_IN |
| 创立/建立/创办 | FOUNDED |
| 毕业于/就读于 | EDUCATED_AT |
```

---

## 知识图谱模式

### 常见领域模式

#### 人物关系图谱

```cypher
// 人物关系模式
(:Person)-[:KNOWS]->(:Person)
(:Person)-[:WORKS_FOR]->(:Organization)
(:Person)-[:EDUCATED_AT]->(:School)
(:Person)-[:BORN_IN]->(:Location)
(:Person)-[:MARRIED_TO]->(:Person)
(:Person)-[:PARENT_OF]->(:Person)
```

#### 企业知识图谱

```cypher
// 企业关系模式
(:Company)-[:SUBSIDIARY_OF]->(:Company)
(:Company)-[:COMPETES_WITH]->(:Company)
(:Company)-[:LOCATED_IN]->(:Location)
(:Company)-[:FOUNDED_BY]->(:Person)
(:Product)-[:PRODUCED_BY]->(:Company)
(:Company)-[:INVESTED_IN]->(:Company)
```

#### 学术知识图谱

```cypher
// 学术关系模式
(:Paper)-[:AUTHORED_BY]->(:Researcher)
(:Paper)-[:CITES]->(:Paper)
(:Paper)-[:PUBLISHED_IN]->(:Journal)
(:Researcher)-[:AFFILIATED_WITH]->(:Institution)
(:Paper)-[:ABOUT]->(:Topic)
```

---

## 图可视化

### D3.js 力导向图

```javascript
// 知识图谱可视化配置
const config = {
  width: 800,
  height: 600,
  nodeRadius: 20,
  linkDistance: 100,
  chargeStrength: -300,

  nodeColors: {
    Person: '#4CAF50',
    Organization: '#2196F3',
    Location: '#FF9800',
    Product: '#9C27B0'
  },

  linkColors: {
    WORKS_FOR: '#666',
    LOCATED_IN: '#999',
    KNOWS: '#CCC'
  }
};

// 数据格式
const graphData = {
  nodes: [
    { id: '1', label: '张三', type: 'Person' },
    { id: '2', label: '科技公司', type: 'Organization' }
  ],
  links: [
    { source: '1', target: '2', type: 'WORKS_FOR' }
  ]
};
```

### Cytoscape.js 配置

```javascript
// Cytoscape 样式配置
const style = [
  {
    selector: 'node',
    style: {
      'label': 'data(label)',
      'background-color': 'data(color)',
      'text-valign': 'center',
      'text-halign': 'center'
    }
  },
  {
    selector: 'edge',
    style: {
      'label': 'data(type)',
      'curve-style': 'bezier',
      'target-arrow-shape': 'triangle',
      'line-color': '#ccc',
      'target-arrow-color': '#ccc'
    }
  },
  {
    selector: 'node[type="Person"]',
    style: {
      'background-color': '#4CAF50'
    }
  }
];
```

---

## 知识问答

### 问答模板

```markdown
## 基于知识图谱的问答

### 问题类型

1. **实体查询**
   - Q: "张三在哪里工作？"
   - Cypher: MATCH (p:Person {name:'张三'})-[:WORKS_FOR]->(c) RETURN c.name

2. **关系查询**
   - Q: "张三和李四是什么关系？"
   - Cypher: MATCH (p1:Person {name:'张三'})-[r]-(p2:Person {name:'李四'}) RETURN type(r)

3. **路径查询**
   - Q: "张三如何认识王五？"
   - Cypher: MATCH path = shortestPath((p1:Person {name:'张三'})-[*]-(p2:Person {name:'王五'})) RETURN path

4. **聚合查询**
   - Q: "科技公司有多少员工？"
   - Cypher: MATCH (p:Person)-[:WORKS_FOR]->(c:Company {name:'科技公司'}) RETURN count(p)

5. **推理查询**
   - Q: "谁是张三的同事？"
   - Cypher: MATCH (p1:Person {name:'张三'})-[:WORKS_FOR]->(c)<-[:WORKS_FOR]-(p2:Person) RETURN p2.name
```

---

## 图算法应用

### 中心性分析

```cypher
// 度中心性 - 连接数最多的节点
MATCH (n)
RETURN n.name, size((n)--()) AS degree
ORDER BY degree DESC
LIMIT 10

// 介数中心性 - 信息传播的关键节点
CALL gds.betweenness.stream('myGraph')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).name, score
ORDER BY score DESC

// 紧密中心性 - 距离其他节点最近的节点
CALL gds.closeness.stream('myGraph')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).name, score
ORDER BY score DESC
```

### 社区发现

```cypher
// Louvain 社区发现
CALL gds.louvain.stream('myGraph')
YIELD nodeId, communityId
RETURN communityId, collect(gds.util.asNode(nodeId).name) AS members
ORDER BY size(members) DESC

// 标签传播
CALL gds.labelPropagation.stream('myGraph')
YIELD nodeId, communityId
RETURN gds.util.asNode(nodeId).name, communityId
```

### 相似度计算

```cypher
// 节点相似度
CALL gds.nodeSimilarity.stream('myGraph')
YIELD node1, node2, similarity
RETURN gds.util.asNode(node1).name AS person1,
       gds.util.asNode(node2).name AS person2,
       similarity
ORDER BY similarity DESC
```

---

## 与 TAD 框架的集成

在 TAD 的知识工程流程中：

```
数据收集 → 知识抽取 → 图谱构建 → 知识融合 → 应用服务
               ↓
          [ 此 Skill ]
```

**使用场景**：
- 知识图谱设计
- 实体关系抽取
- 图数据库操作
- 知识推理查询
- 图可视化

---

## 最佳实践

```
✅ 推荐
□ 先设计本体模式再构建图谱
□ 使用标准化的关系类型
□ 建立实体消歧和融合机制
□ 定期更新和维护图谱
□ 使用索引优化查询性能

❌ 避免
□ 关系类型过于细碎
□ 缺少本体约束导致数据混乱
□ 忽视数据质量问题
□ 图谱规模失控
□ 查询未优化导致性能问题
```

---

*此 Skill 帮助 Claude 进行知识图谱的设计、构建和应用。*
