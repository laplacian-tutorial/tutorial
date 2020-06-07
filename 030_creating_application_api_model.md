# アプリケーションAPIモデルの作成

APIの機能と構成を定義するモデルを作成します。

## 手順

1. **プロジェクトフォルダに移動**

    ```console
    cd laplacian-tutorial
    ```

2. **アプリケーションファンクションモデルプロジェクトを作成**

    `create-new-function-model-project.sh`スクリプトを実行します。
    `project-name`のみ入力し、それ以外は全てデフォルト値を使用します。

    ```console
    $ ./scripts/create-new-function-model-project.sh

    Enter project-name: function-model

    Enter project-version [0.0.1]:

    Enter namespace [laplacian.tutorial]:
    ...

    The new subproject is created at ./subprojects/laplacian-tutorial.function-model/
    ```

    生成されたコードをコミットします。

    ```console
    git add .
    ```

    ```console
    git commit -m 'add function-model subproject.'
    ```

3. **アプリケーションデータアクセスモデルを作成**

    ドメインデータを格納したデータソースへのアクセスを定義するモデルを作成します。

    作成したサブプロジェクトを`VS-Code`で開きます。

    ```console
    code ./subprojects/laplacian-tutorial.function-model/
    ```

    データアクセスモデルを定義する`Yaml`ファイルを`src/datasources`ディレクトリ配下に作成します。

    ![src-dir-explorer](./images/src-dir-explorer.png)

    > `src/datasources/tutorial-db.yaml`

    ```yaml
    datasources:
    - name: tutorial_db
      type: postgres
      user: test
      password: secret
      db_name: tutorial_db
      hostname: localhost
      entity_references:
      - entity_name: task_group
    ```

4. **APIインタフェースモデルを作成**

    次に、APIの定義と、APIが外部に公開するRESTリソースの定義を表すモデルを作成します。

    先に作成したサブプロジェクトの`src/`ディレクトリに下記の`Yaml`ファイルを追加してください。

    > `src/services/tutorial-api.yaml`

    ```yaml
    services:
    - name: tutorial_api
      version: '0.0.1'
      namespace: laplacian.tutorial.api
      datasource_name: tutorial_db
      resource_entries:
      - resource_name: task_group
    ```

    > `src/rest_resources/task-group.yaml`

    ```yaml
    rest_resources:
    - name: task_group
      namespace: laplacian.tutorial.api.rest.resource
      operations:
      - method: GET
        response_body:
        - name: task_groups
          entity_name: task_group
          type: array
    ```

    `VS-Code`のターミナルを開き、`generate.sh`スクリプトを実行し、ドキュメント類の生成と、作成したモデルの検証を行います。

    ```console
    ./scripts/generate.sh
    ```

    問題がなければ、作成したモデルをコミットします。

    ```console
    git add .
    ```

    ```console
    git commit -m 'Add function models concerning the api service.'
    ```

5. **作成したアプリケーションモデルをローカルモジュールリポジトリに登録**

    `VS-Code`のターミナルで`publish-local`スクリプトを実行します。

    ```console
    ./scripts/publish-local.sh
    ```
