/**
 * Builds and returns file's url.
 * @param params, object which has SIZE and UUID
 * Size can be either small, medium or large.
 * @returns file's url
 */
function getFileLink(params) {
  if (params.size) {
    return 'https://eurocore.rocks/files/' + params.size
      + '/' + params.filename.substring(0,2)
      + '/' + params.filename.substring(2,4)
      + '/' + params.filename;
  } else {
    return 'https://eurocore.rocks/files/' + params.filename.substring(0,2)
      + '/' + params.filename.substring(2,4)
      + '/' + params.filename;
  }
}

export default {getFileLink}
