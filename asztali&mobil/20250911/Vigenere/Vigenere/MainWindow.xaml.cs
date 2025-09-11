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
using System.IO;
using System.Text.RegularExpressions;
using System.Security.AccessControl;

namespace Vigenere;

/// <summary>
/// Interaction logic for MainWindow.xaml
/// </summary>
public partial class MainWindow : Window
{
    char[,] Vtabla = new char[26,26];
    string ABC = "";
    public MainWindow()
    {
        InitializeComponent();
        VtablaLoad();
    }

    private void KodolasBtn_Click(object sender, RoutedEventArgs e)
    {
        string NyiltSzoveg = TextNormalise(NyiltSzovegTextBox.Text);

        string KulcsszoNemEllenorzott = TextNormalise(KulcsszoTextBox.Text);
        string Kulcsszo = KulcsszoNemEllenorzott.Length > 5 ? KulcsszoNemEllenorzott.Substring(0, 5) : KulcsszoNemEllenorzott;

        NyiltSzovegFormattedTextBlock.Text = NyiltSzoveg;
        KulcsszoFormattedTextBlock.Text = Kulcsszo;

        string KodoltSzoveg = VigenereKodolas(NyiltSzoveg, Kulcsszo);
        KodoltSzovegTextBlock.Text = KodoltSzoveg;

        File.WriteAllText("Kodolt.dat", KodoltSzoveg);
    }

    private void VtablaLoad()
    { 
        string[] sorok = File.ReadAllLines("Vtabla.dat");

        for (int i = 0; i < 26; i++)
        {
            for (int j = 0; j < 26; j++)
            {
                Vtabla[i, j] = sorok[i][j];
            }
        }

        ABC = sorok[0];
    }

    private string TextNormalise(string NonFormattedText)
    {
        NonFormattedText = NonFormattedText.ToUpper();

        NonFormattedText = NonFormattedText
        .Replace("Á", "A")
        .Replace("É", "E")
        .Replace("Í", "I")
        .Replace("Ó", "O")
        .Replace("Ö", "O")
        .Replace("Ő", "O")
        .Replace("Ú", "U")
        .Replace("Ü", "U")
        .Replace("Ű", "U");

        return Regex.Replace(NonFormattedText, "[^A-Z]", "");
    }

    private string VigenereKodolas(string nyiltSzoveg, string kulcsszo)
    {
        string kulcsSzoveg = "";
        int kulcsszoIndex = 0;
        for (int i = 0; i < nyiltSzoveg.Length; i++)
        {
            kulcsSzoveg += kulcsszo[kulcsszoIndex];
            kulcsszoIndex = kulcsszoIndex+1 > kulcsszo.Length-1 ? 0 : kulcsszoIndex+1;
        }

        string KodoltSzoveg = "";

        for (int i = 0; i < nyiltSzoveg.Length; i++)
        {
            KodoltSzoveg += Vtabla[WichIndexOfABC(nyiltSzoveg[i]), WichIndexOfABC(kulcsSzoveg[i])];
        }

        return KodoltSzoveg;
    }

    private int WichIndexOfABC(char betu)
    {
        for (int i = 0; i < ABC.Length; i++)
        {
            if (ABC[i] == betu) return i;
        }
        return -1;
    }
}