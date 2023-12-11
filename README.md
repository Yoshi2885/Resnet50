# Resnet50

このスクリプトは、iOS, iPadOS向けのリアルタイム推論カメラアプリです。

機械学習による推論モデルは、Appleが公式に出しているResnet50を用いています。

Developperのアカウントをお持ちでしたら、ご自身のデバイスに入れて動作確認をすることができるかと思われます。

## ファイルの説明

ContentView.swift

アプリの画面を表示するのに使用しているファイルです。

動画撮影、取り込み、推論に関しては、CameraView.swiftに記述しています。

## アプリの試し方

本アプリはカメラとの接続を前提としたアプリになっています。

そのため、実機へビルドできる状態にしてください。

実機にビルドしたら「Resnet50」というアプリがインストールされると思います。

アプリを起動したら初回のみ、

カメラの使用許可がポップアップで出ますので承認しアプリを使ってみてください。
