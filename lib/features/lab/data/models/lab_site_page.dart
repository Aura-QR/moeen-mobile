/// Site pages of the virtual lab that have no native screen in the app.
enum LabSitePage {
  create('https://haderedu.com/lab/create'),
  request('https://haderedu.com/lab/request');

  const LabSitePage(this.url);

  final String url;

  Uri get uri => Uri.parse(url);
}
