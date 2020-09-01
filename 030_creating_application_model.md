# アプリケーションモデルの作成

APIの機能と構成を定義するモデルを作成します。

## 手順

1. **プロジェクトフォルダに移動**

    ```console
    cd laplacian-tutorial
    ```

2. **アプリケーションモデルプロジェクトを作成**

    `create-new-application-model-project.sh`スクリプトを実行します。
    ここでは全てデフォルト値を使用するので、リターンを押して進めてください。

    ```console
    $ ./scripts/create-new-application-model-project.sh

    Enter project-name [application-model]:

    Enter project-version [0.0.1]:

    Enter namespace [laplacian.tutorial]:
    ...

    Created the new project's definition at: laplacian-tutorial/model/project/subprojects/laplacian-tutorial/function-model.yaml
    1. Edit this file if you need.
    2. Run ./scripts/generate-function-model.sh to generate the project's content.
    ```

    生成されたプロジェクトモデルファイル(`model/project/subprojects/laplacian-tutorial/application-model.yaml`)をエディタで開き、先に作成したドメインモデルへの参照を追加します。

    ```console
    code .
    ```

    > `model/project/subprojects/laplacian-tutorial/function-model.yaml`

    ```yaml
    _description: &description
      en: |
        The application-model project.

    _project: &project
      group: laplacian-tutorial
      type: application-model
      name: application-model
      namespace: laplacian.tutorial
      description: *description
      version: '0.0.1'
      # Insert the following lines into your project file.
      # From here...
      plugins:
      - group: laplacian-tutorial
        name: domain-model-plugin
        version: '0.0.1'
      models:
      - group: laplacian-tutorial
        name: domain-model
        version: '0.0.1'
      # ... to here.
    project:
      subprojects:
      - *project
    ```

    上記ファイルを元にプロジェクトを生成します。

    ```console
    ./scripts/generate.sh
    ./scripts/generate-application-model.sh
    ```

    生成されたコードをコミットします。

    ```console
    git add .
    ```

    ```console
    git commit -m 'add application-model subproject.'
    ```

3. **API機能モデルを作成**

    APIの機能を定義するモデルを追加します。

    作成したサブプロジェクトを`VS-Code`で開きます。

    ```console
    code ./subprojects/application-model/
    ```

    `src/model`ディレクトリ配下に、下記の各`Yaml`ファイルを作成してください。

    ![src-dir-explorer](./images/src-dir-explorer.png)

    > `src/model/services/tutorial-api.yaml`

    ```yaml
    services:
    - name: tutorial_api
      version: '0.0.1'
      namespace: laplacian.tutorial.api
      datasources:
      - type: postgres
      graphql_type_entries:
      - type_name: task
      - type_name: task_group
    ```

    > `src/model/graphql-types/graphql-types.yaml`

    ```yaml
    graphql_types:
    - entity_name: task
    - entity_name: task_group
    ```

    > `src/model/environments/local.yaml`

    ```yaml
    environments:
    - tier: local
      name: local
      component_entries:
      - name: tutorial_api
      - name: test_db
    ```

    > `src/model/components/tutorial-api.yaml`

    ```yaml
    components:
    - name: tutorial_api
      type: springboot2_api_service
      function_model_name: tutorial_api
      datasource_mappings:
      - name: default
        component_name: test_db
    ```

    > `src/model/components/test-db.yaml`

    ```yaml
    components:
    - name: test_db
      type: postgres_test_db
      username: test
      password: secret
      database_name: tutorial_db
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
    git commit -m 'Add an model concerning the api service.'
    ```

4. **作成したアプリケーションモデルをローカルモジュールリポジトリに登録**

    `VS-Code`のターミナルで`publish-local`スクリプトを実行します。

    ```console
    ./scripts/publish-local.sh
    ```
