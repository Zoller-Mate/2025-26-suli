using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;

namespace harcosok_klubja
{
    
    class Harcos
    {
        public string Nev { get; set; }
        public int Ero { get; set; }
        public int Technika { get; set; }
        public int Allapot { get; set; }
        public int Tamadoero { get; set; }
        public int Gyozelmek { get; set; }


        public Harcos(string nev, int ero, int technika)
        {
            Nev = nev;
            Ero = ero;
            Technika = technika;
            Allapot = 100;
            TamadoeroFrissit();
            Gyozelmek = 0;
        }

        public void TamadoeroFrissit()
        {
            this.Tamadoero = this.Ero * this.Technika * this.Allapot;
        }
    }

    static class Osszecsapas
    {
        static Random rnd = new Random();
        public static Harcos Harcol (Harcos harcos1, Harcos harcos2)
        {
            // minkét harcos támadóerejét frissítjük az állapotnak megfelelően ugye
            harcos1.TamadoeroFrissit();
            harcos2.TamadoeroFrissit();

            // kezdő harcos támadó erő ponjaihoz hozzáadás
            Tamad(harcos1, harcos2);

            // győztes kiválasztása
            Harcos Gyoztes = harcos1.Tamadoero > harcos2.Tamadoero ? harcos1 : harcos2; // győztes kiválasztása

            // figyelembe vesszük a harcosok fáradásás
            AllapotCsokkentes(harcos1);
            AllapotCsokkentes(harcos2);

            return Gyoztes;
        }

        public static void Tamad(Harcos harcos1, Harcos harcos2)
        {
            if (rnd.Next(2) == 0)
            {
                harcos1.Tamadoero += 50000;
            } else
            {
                harcos2.Tamadoero += 50000;
            }
        }

        public static void AllapotCsokkentes(Harcos harcos)
        {
            harcos.Allapot -= rnd.Next(2, 10);
        }

    }

    class Program
    {   
        public static List<Harcos> Harcosok = new List<Harcos>();
        static Random rnd = new Random();
        static void Main(string[] args)
        {
            HarcosokFeltolt();
            List<Harcos[]> Merkozesek = MerkozesekSorsolas();

            foreach (var egyMerkozes in Merkozesek)
            {
                Harcos Gyoztes = Osszecsapas.Harcol(egyMerkozes[0], egyMerkozes[1]);
                Harcos Vesztes = Gyoztes == egyMerkozes[0] ? egyMerkozes[1] : egyMerkozes[0];

                Gyoztes.Gyozelmek += 1;

                Console.WriteLine($"Győztes: {Gyoztes.Nev} ({Gyoztes.Ero}-{Gyoztes.Technika}-{Gyoztes.Allapot})\tVesztes: {Vesztes.Nev} ({Vesztes.Ero}-{Vesztes.Technika}-{Vesztes.Allapot})");
            }

            // a győztes(ek) megkeresése
            int maxGyozelmek = Harcosok.Max(x => x.Gyozelmek);
            var Gyoztesek = Harcosok.Where(x => x.Gyozelmek == maxGyozelmek).ToList();

            foreach (var egyGyoztes in Gyoztesek)
            {
                Console.WriteLine($"\nBajnokság győtese: {egyGyoztes.Nev} - {egyGyoztes.Gyozelmek} győzelemmel.");
            }
        }

        static List<Harcos[]> MerkozesekSorsolas()
        {
            List<Harcos[]> OsszesMerkozes = new List<Harcos[]>();
            for (int i = 0; i < Harcosok.Count(); i++)
            {
                for (int j = i+1; j < Harcosok.Count(); j++)
                {
                    OsszesMerkozes.Add(new Harcos[] { Harcosok[i], Harcosok[j] });
                    //Console.WriteLine(i.ToString() + " " + j.ToString());
                }
            }

            List<Harcos[]> SorsoltMerkozesek = new List<Harcos[]>();
            int harcosokSzama = OsszesMerkozes.Count();
            while (SorsoltMerkozesek.Count() < harcosokSzama)
            {
                Harcos[] RandomMerkozes = OsszesMerkozes[rnd.Next(OsszesMerkozes.Count())];

                // megvizsgáljuk, hogy a kiválaszott mérkőzés megfelelő e nekünk
                if (SorsoltMerkozesek.Count() > 0 && OsszesMerkozes.Count() > 1) // ha nem az első és nem az utolsó mérkőzést sorsoljuk
                {
                    // ha a sorsolt mérkőzés tartalmaz olyan játékost, aki az előzőben is benne volt
                    if (SorsoltMerkozesek.Last().Contains(RandomMerkozes[0]) ||
                        SorsoltMerkozesek.Last().Contains(RandomMerkozes[1]))
                    {
                        continue;
                    }
                }

                SorsoltMerkozesek.Add(RandomMerkozes);
                OsszesMerkozes.Remove(RandomMerkozes);
            }

            return SorsoltMerkozesek;
        }

        static void HarcosokFeltolt()
        {
            var sorok = File.ReadAllLines("h.txt").Select(x => x.Split('@').ToList()).ToList();

            foreach (var sor in sorok)
            {
                //Console.WriteLine(sor[0] + sor[1] + sor[2]);
                Harcosok.Add(new Harcos(sor[0], int.Parse(sor[1]), int.Parse(sor[2])));
            }
        }
    }
}
