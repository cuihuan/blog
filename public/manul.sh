cd ./manual
rm -rf ./*
echo "rm succ"

cp -rf /Users/cuixiaohuan/Desktop/workspace/didibook/manual/* ./
echo "cp succ"

git add ./*
git commit -m "2019-ncov demploy"
git push origin

