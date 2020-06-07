# アプリケーションドメインモデルの作成

アプリケーションの問題領域を表現するドメインモデルを定義します。

## 作業手順

1. **プロジェクトフォルダに移動**

    ```console
    cd laplacian-tutorial
    ```

2. **ドメインモデルプロジェクトを作成**

    `create-new-domain-model-project.sh`スクリプトを実行します。
    `project-name`のみ入力し、それ以外は全てデフォルト値を使用します。

    ```console
    $ ./scripts/create-new-domain-model-project.sh

    Enter project-name: domain-model

    Enter project-version [0.0.1]:

    Enter namespace [laplacian.tutorial]:
    ...

    The new subproject is created at ./subprojects/laplacian-tutorial.domain-model/
    ```

    生成されたコードをコミットします。

    ```console
    git add .
    ```

    ```console
    git commit -m 'add domain-model subproject.'
    ```

3. **ドメインモデルを作成**

    作成したサブプロジェクトを`VS-Code`で開きます。

    ```console
    code ./subprojects/laplacian-tutorial.domain-model/
    ```

    ドメインモデルを定義する`Yaml`ファイルを`src/entities`ディレクトリ配下に作成します。

    ![src-dir-explorer](./images/src-dir-explorer.png)

    > `src/entities/task-group.yaml`

    ```yaml
    entities:
    - name: task_group
      namespace: laplacian.tutorial

      properties:
      - name: id
        type: string
        primary_key: true

      - name: title
        type: string

      - name: color
        type: string
        optional: true
        default_value: |
          "transparent"

      relationships:
      - name: tasks
        reference_entity_name: task
        cardinality: '*'
        aggregate: true
    ```

    > `src/entities/task.yaml`

    ```yaml
    entities:
    - name: task
      namespace: laplacian.tutorial

      properties:
      - name: seq_number
        type: number
        primary_key: true

      - name: title
        type: string

      - name: description
        type: string
        optional: true

      - name: completed
        type: boolean
        optional: true
        default_value: |
          false

      relationships:
      - name: task_group
        cardinality: '1'
        reference_entity_name: task_group
        reverse_of: tasks
    ```

    `VS-Code`のターミナルを開き、`generate.sh`スクリプトを実行します。
    スクリプトでは作成したモデルの検証とソースコード・ドキュメントの生成を行います。

    ```console
    ./scripts/generate.sh
    ```

    モデルの内容に問題があった場合、以下のようなエラーが出力されます。

    ```console
    $ ./scripts/generate.sh

    Caused by: java.lang.IllegalStateException: While merging the model file (laplacian-tutorial/subprojects/laplacian-tutorial.domain-model/.NEXT/dest/entities/task_group.yaml)
    ...
    Caused by: laplacian.util.JsonSchemaValidationError: $.entities[0].relationships[0].cardinality: does not have a value in the enumeration [1, 0..1, *, 1..*]
        at laplacian.util.YamlLoader$Companion.readObjects(YamlLoader.kt:57)
        at laplacian.util.YamlLoader$Companion.readObjects(YamlLoader.kt:36)
        ... 153 more
    ```

    コマンドラインで行われる検証は、`VS-Code`上でも行われ、下図のように、エラー内容をエディタ上で確認できます。

    ![model validation error](./images/model-validation-error.png)

    作成したモデルをコミットします。

    ```console
    git add .
    ```

    ```console
    git commit -m 'Add domain models.'
    ```

4. **作成したドメインモデルをローカルモジュールリポジトリに登録**

    `VS-Code`のターミナルで`publish-local`スクリプトを実行します。

    ```console
    ./scripts/publish-local.sh
    ```

5. **作成したモデルのプラグインを生成し、ローカルモジュールリポジトリに登録**

    `VS-Code`のターミナルで以下のコマンドを実行します。

    ```console
    ./scripts/generate-domain-model.sh
    ```

    ```console
    ./scripts/publish-local-domain-model.sh
    ```

    生成したコードをコミットします。

    ```console
    git add .
    ```

    ```console
    git commit -m 'Add domain-model-plugin'
    ```
