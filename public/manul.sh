cd ./wuhan
rm -rf ./*
echo "rm succ"

cp -rf /Users/cuixiaohuan/Desktop/workspace/didijs/2020_wuhan/* ./
echo "cp succ"

git add ./*
git commit -m "2019-ncov demploy"
git push origin

