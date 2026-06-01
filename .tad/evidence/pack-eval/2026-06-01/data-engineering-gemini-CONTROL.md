### Data Pipeline Architecture Review

As a senior data engineer, I have identified several critical flaws in your current architecture. The most significant risks involve **training-serving skew** and **point-in-time data corruption**, which will likely lead to model performance degradation and security risks.

---

#### **[P0] Training-Serving Skew (Feature Logic Duplication)**
*   **Finding:** You are computing the "30-day order count" separately in a training notebook and a live inference service.
*   **Risk:** This is a classic failure mode. Subtle differences in implementation (e.g., timezone handling, inclusive vs. exclusive date boundaries, handling of "cancelled" vs "pending" orders) will cause the model to see different feature distributions in production than it saw during training.
*   **Recommendation:** Centralize feature logic. Use a **Feature Store** or a shared library/SQL view that both the batch training pipeline and the online inference service consume.

#### **[P0] Data Temporal Integrity (SCD Type 1 for ML Features)**
*   **Finding:** You overwrite customer attributes (tier, city) in the dimension table on change (Slowly Changing Dimension Type 1).
*   **Risk:** This introduces **look-ahead bias** and destroys historical accuracy. If you retrain your model today, it will associate a customer's *current* "Gold" tier with an order they made 20 days ago when they were actually "Silver." The model will "learn" patterns that didn't exist at the time of the event, leading to inflated validation metrics that fail in the real world.
*   **Recommendation:** Implement **SCD Type 2** (versioning with start/end dates) or an **Event Store** architecture. You must be able to perform "point-in-time" joins to see what the customer attributes were at the exact moment an order was placed.

#### **[P1] Multi-tenant Data Leakage & Search Inefficiency**
*   **Finding:** Global vector search followed by application-side filtering for tenants.
*   **Risk:**
    1.  **Security:** Relying on post-filtering is prone to implementation bugs that lead to cross-tenant data leakage.
    2.  **Performance:** Vector index recall (accuracy) often degrades as the "noise" (other tenants' data) increases. You are wasting compute resources retrieving $K$ results only to potentially drop all of them if they don't match the tenant ID.
*   **Recommendation:** Use **Metadata Filtering** (Pre-filtering) at the vector database level. Most modern vector DBs (Pinecone, Weaviate, Milvus) allow you to restrict the search space to a specific `tenant_id` before the nearest-neighbor calculation.

#### **[P1] Semantic Retrieval Blindness (Embedding-Only RAG)**
*   **Finding:** Retrieval is strictly embedding-only.
*   **Risk:** Embeddings are excellent for "concepts" but notoriously poor for specific keywords, product IDs, or proper nouns (e.g., "Order #AZ-123" or "Model X5-Pro"). Customer support queries often hinge on these exact identifiers.
*   **Recommendation:** Implement **Hybrid Search**. Combine vector search with keyword search (BM25/TF-IDF) and use a re-ranker to merge the results.

#### **[P2] Lack of Observability & Lineage**
*   **Finding:** Direct overwrite of dimension tables and notebook-based feature engineering.
*   **Risk:** When the model makes a hallucinated or incorrect prediction, you will have no "audit trail" to determine if the error was due to faulty input data (since the old values were overwritten) or model logic.
*   **Recommendation:** Ensure all feature inputs are logged at inference time to a "Feature Logging" table for future debugging and "Ground Truth" comparison.
