# アプリケーションAPIモデルの作成

APIの機能と構成を定義するモデルを作成します。

## 手順

1. **プロジェクトフォルダに移動**

    ```console
    cd laplacian-tutorial
    ```

2. **アプリケーションファンクションモデルプロジェクトを作成**

    `create-new-function-model-project.sh`スクリプトを実行します。
    ここでは全てデフォルト値を使用するので、リターンを押して進めてください。

    ```console
    $ ./scripts/create-new-function-model-project.sh

    Enter project-name [function-model]:

    Enter project-version [0.0.1]:

    Enter namespace [laplacian.tutorial]:
    ...

    Created the new project's definition at: laplacian-tutorial/model/project/subprojects/laplacian-tutorial/function-model.yaml
    1. Edit this file if you need.
    2. Run ./scripts/generate-function-model.sh to generate the project's content.
    ```

    生成されたプロジェクトモデルファイル(`model/project/subprojects/laplacian-tutorial/function-model.yaml`)をエディタで開き、先に作成したドメインモデルへの参照を追加します。

    ```console
    code .
    ```

    > `model/project/subprojects/laplacian-tutorial/function-model.yaml`

    ```yaml
    _description: &description
      en: |
        The function-model project.

    _project: &project
      group: laplacian-tutorial
      type: function-model
      name: function-model
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
    ./scripts/generate-function-model.sh
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
    code ./subprojects/function-model/
    ```

    データアクセスモデルを定義する`Yaml`ファイルを`src/model/datasources`ディレクトリ配下に作成します。

    ![src-dir-explorer](./images/src-dir-explorer.png)

    > `src/model/datasources/tutorial-db.yaml`

    ```yaml
    datasources:
    - name: tutorial_db
      type: postgres
      db_user: test
      db_password: secret
      db_name: tutorial_db
      hostname: localhost
      entity_references:
      - entity_name: task_group
    ```

4. **APIインタフェースモデルを作成**

    次に、APIの定義と、APIが外部に公開するRESTリソースの定義を表すモデルを作成します。

    先に作成したサブプロジェクトの`src/model/services`ディレクトリおよび、`src/model/rest-resources/`ディレクトリに下記の`Yaml`ファイルを追加してください。

    > `src/model/services/tutorial-api.yaml`

    ```yaml
    services:
    - name: tutorial_api
      version: '0.0.1'
      namespace: laplacian.tutorial.api
      datasource_name: tutorial_db
      resource_entries:
      - resource_name: task_group
    ```

    > `src/model/rest_resources/task-group.yaml`

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
