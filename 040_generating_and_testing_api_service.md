# APIサービスの生成と動作確認

アプリケーションAPIモデルから、APIサービスの実装を生成し、ローカルでの動作を確認します。

## 作業手順

1. **プロジェクトフォルダに移動**

    ```console
    cd laplacian-tutorial
    ```

2. **APIサービスプロジェクトを作成**

    `create-new-java-stack-service-generator-project.sh`スクリプトを実行します。
    ここでは全てデフォルト値を使用するので、リターンを押して進めてください。

    ```console
    $ ./scripts/create-new-java-stack-service-project.sh

    Enter project-name [java-stack-service]:

    Enter project-version [0.0.1]:

    Enter namespace [laplacian.tutorial]:
    ...

    The new subproject is created at ./subprojects/laplacian-tutorial.api-service/
    ```

    生成されたプロジェクトファイル (`src/project/subprojects/laplacian-tutorial/api-service.yaml`)をエディタで開き、先に作成したドメインモデルとファンクションモデルへの参照を追加します。

    ```console
    code .
    ```

    > `src/project/subprojects/laplacian-tutorial/java-stack-service.yaml`

    ```yaml
    _description: &description
      en: |
        The api-service project.

    _project: &project
      group: laplacian-tutorial
      type: java-stack-service
      name: java-stack-service
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
      - group: laplacian-tutorial
        name: function-model
        version: '0.0.1'
      # ... to here.
    project:
      subprojects:
      - *project
    ```

3. **APIサービスを自動生成**

    この変更を反映するため、プロジェクトの再生成を行います。

    ```console
    ./scripts/generate.sh
    ```

    ```console
    ./scripts/generate-java-stack-service.sh
    ```

    プロジェクトモデルと生成されたコードをコミットします。

    ```console
    git add .
    ```

    ```console
    git commit -m 'add a project for a java stack implementation of the service.'
    ```

4. **生成されたサービスをローカルで起動し動作を確認**
