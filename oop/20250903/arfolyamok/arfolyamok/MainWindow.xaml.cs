using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using MySql.Data.MySqlClient;
using System.Data;
using Org.BouncyCastle.Asn1.Cmp;

namespace arfolyamok;

/// <summary>
/// Interaction logic for MainWindow.xaml
/// </summary>
public partial class MainWindow : Window
{
    string connStr = "server=localhost;user=root;database=deviza_atvalto;port=3306;password=;";
    public MainWindow()
    {
        InitializeComponent();
        LoadDates(dateComboBox);
        LoadDates(dateComboBox3);
        LoadDates(dateComboBox4);
        LoadValutas(valutaComboBox2);
        LoadValutas(valutaComboBox3_alap);
        LoadValutas(valutaComboBox3_cel);
        LoadValutas(valutaComboBox4);
    }

    private void LoadDates(ComboBox datumValaszto)
    {
        using (var conn = new MySqlConnection(connStr))
        {
            conn.Open();
            string sql = "SELECT datum FROM exchange_rates ORDER BY datum DESC";
            using (var cmd = new MySqlCommand(sql, conn))
            using (var reader = cmd.ExecuteReader())
            {
                while (reader.Read())
                {
                    string date = reader.GetDateTime("datum").ToString("yyyy-MM-dd");
                    datumValaszto.Items.Add(date);
                }
            }
        }
    }

    private void Lekerdez_btn_1_Click(object sender, RoutedEventArgs e)
    {
        if (dateComboBox.SelectedItem is null)
        {
            MessageBox.Show("Válassz dátumot!");
            return;
        }
        string selected_datum = dateComboBox.Text;

        using (var conn = new MySqlConnection(connStr))
        {
            conn.Open();
            string elso_lekerdezes = "SELECT * FROM exchange_rates WHERE datum = @selected_datum";

            using (var cmd = new MySqlCommand(elso_lekerdezes, conn))
            {
                cmd.Parameters.AddWithValue("@selected_datum", selected_datum);

                MySqlDataAdapter da = new MySqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                eredmenyDataGrid1.ItemsSource = dt.DefaultView;
            }
        }
    }


    private void LoadValutas(ComboBox valutaValaszto)
    {
        string[] valutas = new string[] { "CHF", "EUR" ,"GBP", "PLN","RON", "RUB" ,	"SEK","TRY", "UAH" ,"USD" };
        valutaValaszto.ItemsSource = valutas;
    }
    private void Lekerdez_btn_2_Click(object sender, RoutedEventArgs e)
    {
        if (valutaComboBox2.SelectedItem is null)
        {
            MessageBox.Show("Válassz valutát!");
            return;
        }
        string selected_valuta = valutaComboBox2.Text;

        using (var conn = new MySqlConnection(connStr))
        {
            conn.Open();
            string elso_lekerdezes = $"SELECT datum, {selected_valuta} FROM exchange_rates";

            using (var cmd = new MySqlCommand(elso_lekerdezes, conn))
            {

                MySqlDataAdapter da = new MySqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                eredmenyDataGrid2.ItemsSource = dt.DefaultView;
            }
        }
    }

    private void valutaAtvalton_btn_Click(object sender, RoutedEventArgs e)
    {
        double alapValutaMennyiseg; // az ellenörzés alatt már beleírjuk a mennyiséget

        // ellenörzés, hogy minden kötelező helyre jó adatok vannak írva
        if (valutaComboBox3_alap.SelectedItem is null || 
            valutaComboBox3_cel.SelectedItem is null ||
            dateComboBox3.SelectedItem is null ||
            !double.TryParse(alapValutaTextBox.Text, out alapValutaMennyiseg)
            )
        {
            MessageBox.Show("Minden adatot adj meg helyesen a valuta átváltáshoz!");
            return;
        }

        // GUI-ról adatok lecuppantása
        string alapValuta = valutaComboBox3_alap.Text;
        string celValuta = valutaComboBox3_cel.Text;
        string datumValtashoz = dateComboBox3.Text;


        // adatbázisból árfolyamok kicuppantása
        double alapArfolyam;
        double celArfolyam;

        using (var conn = new MySqlConnection(connStr))
        {
            conn.Open();

            string alapArfolyamSql = $"SELECT `{alapValuta}` FROM exchange_rates WHERE datum = '{datumValtashoz}'";
            string celArfolyamSql = $"SELECT `{celValuta}` FROM exchange_rates WHERE datum = '{datumValtashoz}'";

            using (var cmd = new MySqlCommand(alapArfolyamSql, conn))
            {
                alapArfolyam = Convert.ToDouble(cmd.ExecuteScalar());
            }

            using (var cmd = new MySqlCommand(celArfolyamSql, conn))
            {
                celArfolyam = Convert.ToDouble(cmd.ExecuteScalar());
            }
        }

        // átváltás számolás
        double celValutaMennyiseg = alapArfolyam * alapValutaMennyiseg / celArfolyam;

        celValutaTextBlock.Text = celValutaMennyiseg.ToString();
    }

    private void Lekerdez_btn_4_Click(object sender, RoutedEventArgs e)
    {
        if (dateComboBox4.SelectedItem is null || valutaComboBox4 is null)
        {
            MessageBox.Show("Válassz dátumot és valutát!");
            return;
        }

        string valasztottDatum = dateComboBox4.Text;
        string valasztottValuta = valutaComboBox4.Text;

        double napiValuta;

        using (var conn = new MySqlConnection(connStr))
        {
            conn.Open();

            string napiValuta_sql = $"SELECT {valasztottValuta} FROM exchange_rates WHERE datum = '{valasztottDatum}'";

            using (var cmd = new MySqlCommand(napiValuta_sql, conn))
            {
                napiValuta = Convert.ToDouble(cmd.ExecuteScalar());
            }
        }

        napiValutaTextBox.Text = napiValuta.ToString();
    }
}