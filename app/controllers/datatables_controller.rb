class DatatablesController < ApplicationController
  def datatable_i18n
    if I18n.default_locale == :de
      locale = {
          'sEmptyTable'=>     'Keine Daten verfügbar für diese Tabelle',
          'sInfo'=>           'Zeige _START_ bis _END_ von _TOTAL_ Einträgen',
          'sInfoEmpty'=>      'Zeige 0 bis 0 von 0 Einträgen',
          'sInfoFiltered'=>   '(gefiltert aus _MAX_ gesamten Einträgen)',
          'sInfoPostFix'=>    '',
          'sInfoThousands'=>  ',',
          'sLengthMenu'=>     '_MENU_ Einträgen pro Seite',
          'sLoadingRecords'=> 'Lade...',
          'sProcessing'=>     'wird verarbeitet...',
          'sSearch'=>         'Suchen:',
          'sZeroRecords'=>    'Keine passenden Einträge gefunden',
          'oPaginate'=> {
              'sFirst'=>    'Erste',
              'sLast'=>     'Letzte',
              'sNext'=>     'Nächste',
              'sPrevious'=> 'Vorherige'
          },
          'oAria'=> {
              'sSortAscending'=>  ': aktiveren um Spalte aufsteigend zu sortieren',
              'sSortDescending'=> ':aktiveren um Spalte absteigend zu sortieren'
          }
      }
    else
      locale = {
          'sEmptyTable'=>     'No data available in table',
          'sInfo'=>           'Showing _START_ to _END_ of _TOTAL_ entries',
          'sInfoEmpty'=>      'Showing 0 to 0 of 0 entries',
          'sInfoFiltered'=>   '(filtered from _MAX_ total entries)',
          'sInfoPostFix'=>    '',
          'sInfoThousands'=>  ',',
          'sLengthMenu'=>     '_MENU_ records per page',
          'sLoadingRecords'=> 'Loading...',
          'sProcessing'=>     'Processing...',
          'sSearch'=>         'Search:',
          'sZeroRecords'=>    'No matching records found',
          'oPaginate'=> {
              'sFirst'=>    'First',
              'sLast'=>     'Last',
              'sNext'=>     'Next',
              'sPrevious'=> 'Previous'
          },
          'oAria'=> {
              'sSortAscending'=>  ': activate to sort column ascending',
              'sSortDescending'=> ': activate to sort column descending'
          }
      }
    end
    render :json => locale
  end

end