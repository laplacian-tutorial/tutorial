# プロジェクトグループの作成

アプリケーションを構成する各プロジェクトを管理するプロジェクトグループを作成します。

## 作業手順

1. **プロジェクトフォルダを作成**

    ```console
    mkdir laplacian-tutorial
    ```

    ```console
    cd laplacian-tutorial
    ```

    ``` console
    git init
    ```

2. **自動生成基盤をインストール**

    ```console
    $ curl -Ls 'https://raw.githubusercontent.com/laplacian-arch/projects/master/scripts/install.sh' | bash

    Installing Laplacian Generator scripts..
    .. Finished.
    After editing ./model/project.yaml, run ./scripts/generate.sh to generate this project.
    ```

3. **プロジェクト定義ファイルを編集**

    生成されたプロジェクトファイル (`model/project.yaml`) の内容を開いて必要な箇所を修正します。
    この手順の例では特に修正の必要は無いので、そのまま進めます。

    ```console
    code .
    ```

    > `model/project.yaml`

    ```yaml
    project:
      group: laplacian-tutorial
      name: projects
      type: project-group
      version: "1.0.0"
      description:
        en: |
           projects.
      module_repositories:
        local:
          ../mvn-repo
        remote:
        - https://github.com/nabla-squared/mvn-repo
      models:
      - group: 'laplacian-arch'
        name: 'project-types'
        version: '1.0.0'
    ```

4. **自動生成スクリプトを実行**

    ```console
    ./scripts/generate.sh
    ```

    ```console
    git add .
    ```

    ```console
    git commit -m 'initial commit'
    ```
