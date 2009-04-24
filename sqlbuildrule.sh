#!/bin/bash
cd "${TARGET_BUILD_DIR}"
if [ -f ${INPUT_FILE_BASE}.db ];
then
rm ${INPUT_FILE_BASE}.db;
fi
cat "${INPUT_FILE_PATH}" | sqlite3 ${INPUT_FILE_BASE}.db
